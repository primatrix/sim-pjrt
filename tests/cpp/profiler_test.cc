#include "src/profiler.h"

#include <chrono>
#include <thread>

#include "google/protobuf/util/message_differencer.h"
#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"
#include "tsl/profiler/protobuf/xplane.pb.h"

namespace xla::sim {
namespace {
using tensorflow::profiler::XSpace;
TEST(ProfilerTest, DeclaredKernelCostsAreSeparateFromDotFlops) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  const int64_t now = std::chrono::duration_cast<std::chrono::nanoseconds>(
                          std::chrono::system_clock::now().time_since_epoch())
                          .count();
  ProfileCall call("submit");
  call.activity().Interval("attention", now, now, 0, "HLO", {}, {}, 160, 800,
                           40, "pallas_cost_estimate");
  StopProfile(session);
  XSpace space;
  ASSERT_TRUE(space.ParseFromString(session->Serialize()));
  int kernels = 0;
  for (const auto& plane : space.planes()) {
    for (const auto& line : plane.lines()) {
      for (const auto& event : line.events()) {
        if (plane.event_metadata().at(event.metadata_id()).name() !=
            "attention")
          continue;
        ++kernels;
        int checked = 0;
        for (const auto& stat : event.stats()) {
          const auto& name =
              plane.stat_metadata().at(stat.metadata_id()).name();
          if (name == "kernel_flops") {
            EXPECT_EQ(stat.double_value(), 800);
            ++checked;
          }
          if (name == "dot_flops") {
            EXPECT_EQ(stat.double_value(), 0);
            ++checked;
          }
          if (name == "transcendentals") {
            EXPECT_EQ(stat.double_value(), 40);
            ++checked;
          }
          if (name == "cost_source") {
            EXPECT_EQ(stat.str_value(), "pallas_cost_estimate");
            ++checked;
          }
        }
        EXPECT_EQ(checked, 4);
      }
    }
  }
  EXPECT_EQ(kernels, 1);
}

TEST(ProfilerTest, StopClipsRuntimeReservationsAndOmitsFutureWork) {
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  const int64_t now = std::chrono::duration_cast<std::chrono::nanoseconds>(
                          std::chrono::system_clock::now().time_since_epoch())
                          .count();
  ProfileCall call("submit");
  call.activity().Interval("started", now, now + 10000000000, 0, "HLO");
  call.activity().Interval("future", now + 10000000000, now + 20000000000, 0,
                           "HLO");
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
  ASSERT_EQ(space.planes_size(), 2);
  EXPECT_EQ(space.planes(0).lines(0).events_size(), 1);
  EXPECT_EQ(space.planes(1).lines(0).events_size(), 1);
  auto correlation = [](const auto& plane) {
    for (const auto& stat : plane.lines(0).events(0).stats()) {
      if (plane.stat_metadata().at(stat.metadata_id()).name() ==
          "correlation_id") {
        return stat.uint64_value();
      }
    }
    return uint64_t{0};
  };
  EXPECT_NE(correlation(space.planes(0)), 0);
  EXPECT_EQ(correlation(space.planes(0)), correlation(space.planes(1)));
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
  const auto& plane = space.planes(1);
  bool incomplete = false;
  for (const auto& stat : plane.lines(0).events(0).stats()) {
    if (plane.stat_metadata().at(stat.metadata_id()).name() == "incomplete") {
      incomplete = stat.int64_value();
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
