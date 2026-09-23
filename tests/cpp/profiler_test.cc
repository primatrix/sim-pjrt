#include "src/profiler.h"

#include <chrono>
#include <set>
#include <thread>

#include "google/protobuf/util/message_differencer.h"
#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"
#include "tsl/profiler/protobuf/xplane.pb.h"

namespace xla::sim {
namespace {
using tensorflow::profiler::XSpace;
TEST(ProfilerTest, DeferredActivitiesRespectStopAndEventLimit) {
  ProfileSession session(3);
  ProfileEvent base;
  base.name = "model";
  base.start_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(
      std::chrono::system_clock::now().time_since_epoch()).count();
  base.simulated = true;
  base.device_id = 0;
  auto activities = std::make_shared<std::vector<BundleActivity>>(5);
  for (auto& activity : *activities) {
    activity.name = "op";
    activity.track = "XLA Ops";
    activity.end_ns = 1000000000;
  }
  session.DeferActivities(base, static_cast<size_t>(-1), activities);
  session.Stop();
  session.DeferActivities(base, static_cast<size_t>(-1), activities);
  activities.reset();  // Session owns executable metadata through collection.
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session.Serialize()));
  int count = 0, incomplete = 0;
  for (const auto& plane : space.planes())
    for (const auto& line : plane.lines())
      for (const auto& event : line.events()) {
        ++count;
        for (const auto& stat : event.stats())
          if (plane.stat_metadata().at(stat.metadata_id()).name() == "incomplete")
            incomplete += stat.int64_value();
      }
  EXPECT_EQ(count, 3);
  EXPECT_EQ(incomplete, 3);
  ASSERT_EQ(space.warnings_size(), 1);
  EXPECT_EQ(space.warnings(0), "PJRT simulator dropped 2 events");
}

TEST(ProfilerTest, HostStagesShareActualThreadAndExecutionCorrelation) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  {
    ProfileCall parent("execute");
    parent.activity().SetProgram(7, 8, 1);
    ProfileCall child("prepare", {}, &parent.activity());
    EXPECT_EQ(child.activity().correlation_id(), parent.activity().correlation_id());
  }
  StopProfile(session);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  ASSERT_EQ(space.planes_size(), 1);
  const auto& plane = space.planes(0);
  EXPECT_EQ(plane.name(), "/host:CPU");
  ASSERT_EQ(plane.lines_size(), 1);
  const auto& line = plane.lines(0);
  ASSERT_EQ(line.events_size(), 2);
  EXPECT_LE(line.events(0).offset_ps(), line.events(1).offset_ps());
  EXPECT_GE(line.events(0).offset_ps() + line.events(0).duration_ps(),
            line.events(1).offset_ps() + line.events(1).duration_ps());
  for (const auto& event : line.events()) {
    bool found = false;
    for (const auto& stat : event.stats()) {
      if (plane.stat_metadata().at(stat.metadata_id()).name() == "program_id") {
        EXPECT_EQ(stat.uint64_value(), 7);
        found = true;
      }
    }
    EXPECT_TRUE(found);
  }
}

TEST(ProfilerTest, NativeDeviceIdsStayDistinctInStreamingViewer) {
  ProfileSession session;
  for (int device = 0; device < 8; ++device) {
    ProfileEvent event;
    event.name = "model";
    event.track = "XLA Modules";
    event.device_id = device;
    event.simulated = true;
    session.Begin(event);
  }
  session.Stop();
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session.Serialize()));
  ASSERT_EQ(space.planes_size(), 8);
  for (int i = 0; i < 8; ++i) {
    EXPECT_EQ(space.planes(i).name(), "/device:TPU:" + std::to_string(i));
    EXPECT_EQ(space.planes(i).id(), 2 + i);
    // Streaming conversion clamps 1 + plane.id() > 500 to device 1.
    EXPECT_LE(1 + space.planes(i).id(), 500);
  }
}

TEST(ProfilerTest, SparseCorePlanesUseNativeTracksAndDistinctIds) {
  ProfileSession session;
  for (int device = 0; device < 8; ++device) {
    ProfileEvent event;
    event.name = "model";
    event.track = "XLA Modules";
    event.device_id = device;
    event.simulated = true;
    session.Begin(event);
    for (int core = 0; core < 2; ++core) {
      event.sparse_core = core;
      for (const char* track : {"Sparse Core Modules", "Sparse Core Ops",
                                "SparseCore Offload Type"}) {
        event.track = track;
        session.Begin(event);
      }
    }
  }
  session.Stop();
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session.Serialize()));
  ASSERT_EQ(space.planes_size(), 24);
  std::set<int64_t> ids;
  int sparse_planes = 0;
  for (const auto& plane : space.planes()) {
    EXPECT_TRUE(ids.insert(plane.id()).second);
    EXPECT_LE(1 + plane.id(), 500);
    if (plane.name().find(" SparseCore ") == std::string::npos) continue;
    ++sparse_planes;
    std::set<int64_t> lines;
    for (const auto& line : plane.lines()) lines.insert(line.id());
    EXPECT_EQ(lines, (std::set<int64_t>{66, 67, 145}));
  }
  EXPECT_EQ(sparse_planes, 16);
}

TEST(ProfilerTest, AsyncLanesDoNotCrossAndHostLagIsNotDeviceWork) {
  ProfileSession session;
  const int64_t epoch = std::chrono::duration_cast<std::chrono::nanoseconds>(
                            std::chrono::system_clock::now().time_since_epoch())
                            .count();
  auto add = [&](const char* name, int64_t start, int64_t end,
                 const char* track, bool simulated) {
    ProfileEvent event;
    event.name = name;
    event.start_ns = epoch + start;
    event.end_ns = epoch + end;
    event.device_id = 0;
    event.track = track;
    event.simulated = simulated;
    session.Begin(event);
  };
  // Deliberately insert out of chronological order, with crossing intervals.
  add("second", 20, 40, "Runtime notification", false);
  add("first", 10, 30, "Runtime notification", false);
  add("third", 40, 50, "Runtime notification", false);
  add("model", 10, 20, "XLA Modules", true);
  add("other", 20, 30, "Other model resource", true);
  session.Stop();
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session.Serialize()));
  ASSERT_EQ(space.planes_size(), 2);
  int host_lanes = 0, device_lanes = 0;
  for (const auto& plane : space.planes()) {
    const bool device =
        plane.name().find("/device:TPU:0") != std::string::npos;
    for (const auto& line : plane.lines()) {
      device ? ++device_lanes : ++host_lanes;
      int64_t end = -1;
      for (const auto& event : line.events()) {
        EXPECT_GE(event.offset_ps(), end);
        end = event.offset_ps() + event.duration_ps();
        const auto& name =
            plane.event_metadata().at(event.metadata_id()).name();
        if (device) EXPECT_TRUE(name == "model" || name == "other");
      }
    }
  }
  EXPECT_EQ(host_lanes, 2);
  EXPECT_EQ(device_lanes, 2);
}

TEST(ProfilerTest, ActivityDetailAndCorrelationSurviveExport) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  const int64_t now = std::chrono::duration_cast<std::chrono::nanoseconds>(
                          std::chrono::system_clock::now().time_since_epoch())
                          .count();
  ProfileCall call("submit", "model");
  call.activity().SetProgram(42, 1, 1);
  auto activities = std::make_shared<std::vector<BundleActivity>>(1);
  auto& op = activities->front();
  op.name = "fusion.1";
  op.track = "XLA Ops";
  op.end_ns = 500;
  op.bytes = 4096;
  op.detail = "module=fusion.1; callsite=0:0x2";
  call.activity().Activities("model", now - 1000, 0, true, activities);
  StopProfile(session);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  int transfers = 0;
  for (const auto& plane : space.planes()) {
    for (const auto& line : plane.lines()) {
      for (const auto& event : line.events()) {
        if (plane.event_metadata().at(event.metadata_id()).name() !=
            "fusion.1")
          continue;
        ++transfers;
        EXPECT_EQ(line.name(), "XLA Ops");
        EXPECT_EQ(event.duration_ps(), 500000);
        bool detail = false, program = false, correlation = false,
             bytes = false;
        for (const auto& stat : event.stats()) {
          const auto& name =
              plane.stat_metadata().at(stat.metadata_id()).name();
          if (name == "detail")
            detail =
                (stat.has_ref_value()
                     ? plane.stat_metadata().at(stat.ref_value()).name()
                     : stat.str_value()) == "module=fusion.1; callsite=0:0x2";
          if (name == "program_id") program = stat.uint64_value() == 42;
          if (name == "correlation_id")
            correlation =
                stat.uint64_value() == call.activity().correlation_id();
          if (name == "bytes") bytes = stat.int64_value() == 4096;
        }
        EXPECT_TRUE(detail && program && correlation && bytes);
      }
    }
  }
  EXPECT_EQ(transfers, 1);
}

TEST(ProfilerTest, StopClipsRuntimeReservationsAndOmitsFutureWork) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  const int64_t now = std::chrono::duration_cast<std::chrono::nanoseconds>(
                          std::chrono::system_clock::now().time_since_epoch())
                          .count();
  ProfileCall call("submit");
  call.activity().Interval("started", now, now + 10000000000, 0, "XLA Modules");
  call.activity().Interval("future", now + 10000000000, now + 20000000000, 0,
                           "XLA Modules");
  StopProfile(session);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  int simulated = 0;
  for (const auto& plane : space.planes()) {
    for (const auto& line : plane.lines()) {
      for (const auto& event : line.events()) {
        const std::string& name =
            plane.event_metadata().at(event.metadata_id()).name();
        EXPECT_NE(name, "future");
        if (name != "started") continue;
        ++simulated;
        EXPECT_LT(event.duration_ps(), 10000000000000);
        bool incomplete = false;
        for (const auto& stat : event.stats())
          if (plane.stat_metadata().at(stat.metadata_id()).name() ==
              "incomplete")
            incomplete = stat.int64_value();
        EXPECT_TRUE(incomplete);
      }
    }
  }
  EXPECT_EQ(simulated, 1);
}

TEST(ProfilerTest, AssociatesExecutionsWithPrograms) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  {
    ProfileCall first("PJRT Execute submit", "model");
    first.activity().SetProgram(7, 8, 1);
    ProfileCall second("PJRT Execute submit", "model");
    second.activity().SetProgram(7, 8, 1);
  }
  StopProfile(session);
  session->SetProgram(0, 9, 1, 1);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  const auto& plane = space.planes(0);
  for (const auto& event : plane.lines(0).events()) {
    int64_t program_id = 0, devices = 0;
    for (const auto& stat : event.stats()) {
      const std::string& name =
          plane.stat_metadata().at(stat.metadata_id()).name();
      if (name == "program_id") program_id = stat.uint64_value();
      if (name == "num_devices") devices = stat.int64_value();
    }
    EXPECT_EQ(program_id, 7);
    EXPECT_EQ(devices, 8);
  }
  ASSERT_OK_AND_ASSIGN(auto next, StartProfile());
  StopProfile(next);
}

TEST(ProfilerTest, CapturesHostAndAsyncCompletionWithSharedCorrelation) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  auto [promise, future] = MakePromise();
  {
    ProfileCall call("Execute", "test executable");
    call.activity().Ready(future, "ExecuteReady", 1);
  }
  promise.Set();
  StopProfile(session);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  ASSERT_EQ(space.planes_size(), 1);
  ASSERT_EQ(space.planes(0).lines_size(), 2);
  EXPECT_EQ(space.planes(0).lines(0).events_size(), 1);
  EXPECT_EQ(space.planes(0).lines(1).events_size(), 1);
  auto correlation = [](const auto& plane, int line) {
    for (const auto& stat : plane.lines(line).events(0).stats()) {
      if (plane.stat_metadata().at(stat.metadata_id()).name() ==
          "correlation_id") {
        return stat.uint64_value();
      }
    }
    return uint64_t{0};
  };
  EXPECT_NE(correlation(space.planes(0), 0), 0);
  EXPECT_EQ(correlation(space.planes(0), 0), correlation(space.planes(0), 1));
}

TEST(ProfilerTest, StopClipsPendingEventsAndIgnoresLateCallbacks) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  auto [promise, future] = MakePromise();
  {
    ProfileCall call("Execute");
    call.activity().Ready(future, "ExecuteReady", 0);
  }
  StopProfile(session);
  const std::string stopped = session->Serialize();
  promise.Set();
  XSpace after;
  ASSERT_TRUE(after.ParseFromString(session->Serialize()));
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(stopped));
  EXPECT_TRUE(google::protobuf::util::MessageDifferencer::Equals(space, after));
  const auto& plane = space.planes(0);
  bool incomplete = false;
  for (const auto& line : plane.lines()) {
    for (const auto& event : line.events()) {
      if (plane.event_metadata().at(event.metadata_id()).name() != "ExecuteReady") continue;
      for (const auto& stat : event.stats()) {
        if (plane.stat_metadata().at(stat.metadata_id()).name() == "incomplete")
          incomplete = stat.int64_value();
      }
    }
  }
  EXPECT_TRUE(incomplete);
}

TEST(ProfilerTest, EnforcesOneActiveSessionAndSupportsRestart) {
  ASSERT_OK_AND_ASSIGN(auto first, StartProfile());
  EXPECT_EQ(StartProfile().status().code(), absl::StatusCode::kAlreadyExists);
  {
    ProfileCall call("first");
  }
  StopProfile(first);
  ASSERT_OK_AND_ASSIGN(auto second, StartProfile());
  StopProfile(first);  // An old handle cannot stop a new session.
  {
    ProfileCall call("second");
  }
  StopProfile(second);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(second->Serialize()));
  ASSERT_EQ(space.planes_size(), 1);
  const auto& plane = space.planes(0);
  EXPECT_EQ(
      plane.event_metadata().at(plane.lines(0).events(0).metadata_id()).name(),
      "second");
}

TEST(ProfilerTest, BoundedCollectionReportsDroppedEvents) {
  ProfileSession session(1);
  ProfileEvent event;
  event.name = "bounded";
  session.Begin(event);
  session.Begin(event);
  session.Stop();
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session.Serialize()));
  ASSERT_EQ(space.planes_size(), 1);
  EXPECT_EQ(space.planes(0).lines(0).events_size(), 1);
  ASSERT_EQ(space.warnings_size(), 1);
}
TEST(ProfilerTest, ConcurrentCallbacksPreserveErrorsAndSessionIsolation) {
  ASSERT_OK_AND_ASSIGN(auto first, StartProfile());
  auto [late_promise, late_future] = MakePromise();
  {
    ProfileCall call("old");
    call.activity().Ready(late_future, "late", 0);
  }
  StopProfile(first);
  ASSERT_OK_AND_ASSIGN(auto second, StartProfile());
  auto worker = [] {
    for (int i = 0; i < 32; ++i) {
      ProfileCall call("parallel");
      auto [promise, future] = MakePromise();
      call.activity().Ready(future, "failed", 0);
      promise.Set(absl::InternalError("test failure"));
    }
  };
  std::thread a(worker), b(worker);
  late_promise.Set();
  a.join();
  b.join();
  StopProfile(second);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(second->Serialize()));
  int events = 0, errors = 0;
  for (const auto& plane : space.planes()) {
    for (const auto& line : plane.lines()) {
      for (const auto& event : line.events()) {
        ++events;
        EXPECT_NE(plane.event_metadata().at(event.metadata_id()).name(),
                  "late");
        for (const auto& stat : event.stats()) {
          if (plane.stat_metadata().at(stat.metadata_id()).name() == "error")
            ++errors;
        }
      }
    }
  }
  EXPECT_EQ(events, 128);
  EXPECT_EQ(errors, 64);
}

}  // namespace
}  // namespace xla::sim
