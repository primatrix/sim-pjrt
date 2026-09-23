#include "src/profiler.h"

#include <algorithm>
#include <atomic>
#include <limits>
#include <map>
#include <utility>

#include "absl/strings/str_cat.h"
#include "tsl/platform/env.h"
#include "tsl/profiler/protobuf/xplane.pb.h"
#include "xla/tsl/profiler/utils/xplane_builder.h"

namespace xla::sim {
namespace {
std::shared_ptr<ProfileSession> active_session;
std::mutex session_mutex;
std::atomic<uint64_t> next_correlation{1};
constexpr size_t kDropped = std::numeric_limits<size_t>::max();
int64_t Now() { return tsl::Env::Default()->NowNanos(); }
}  // namespace

ProfileSession::ProfileSession(size_t max_events)
    : max_events_(max_events), start_ns_(Now()) {}

size_t ProfileSession::Begin(ProfileEvent event, size_t parent) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_) return kDropped;
  if (events_.size() + deferred_.size() >= max_events_) {
    ++dropped_events_;
    return kDropped;
  }
  if (parent < events_.size()) {
    event.program_id = events_[parent].program_id;
    event.num_devices = events_[parent].num_devices;
    event.num_replicas = events_[parent].num_replicas;
  }
  if (!event.start_ns) event.start_ns = Now();
  events_.push_back(std::move(event));
  return events_.size() - 1;
}

void ProfileSession::DeferActivities(
    ProfileEvent event, size_t parent,
    std::shared_ptr<const std::vector<BundleActivity>> activities) {
  if (!activities || activities->empty()) return;
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_) return;
  if (events_.size() + deferred_.size() >= max_events_) {
    ++dropped_events_;
    return;
  }
  if (parent < events_.size()) {
    event.program_id = events_[parent].program_id;
    event.num_devices = events_[parent].num_devices;
    event.num_replicas = events_[parent].num_replicas;
  }
  deferred_.push_back({std::move(event), std::move(activities)});
}

void ProfileSession::Finish(size_t index, const absl::Status& status) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_ || index >= events_.size() || events_[index].end_ns) return;
  events_[index].end_ns = std::max(Now(), events_[index].start_ns);
  if (!status.ok()) events_[index].error = status.ToString();
}

void ProfileSession::SetBuffer(size_t index, uint64_t id, int64_t bytes,
                               int64_t device) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_ || index >= events_.size()) return;
  events_[index].buffer_id = id;
  events_[index].bytes = bytes;
  events_[index].device_id = device;
}

void ProfileSession::Stop() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_) return;
  stopped_ = true;
  const int64_t end = Now();
  stopped_ns_ = end;
  for (ProfileEvent& event : events_) {
    if (!event.end_ns || event.end_ns > end) {
      event.end_ns = std::max(end, event.start_ns);
      event.incomplete = true;
    }
  }
}

void ProfileSession::SetLinks(size_t index, std::string inputs,
                              std::string outputs) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_ || index >= events_.size()) return;
  events_[index].input_buffers = std::move(inputs);
  events_[index].output_buffers = std::move(outputs);
}

std::string ProfileSession::Serialize() const {
  std::lock_guard<std::mutex> lock(mutex_);
  // Expand immutable executable metadata only during collection, never while
  // holding the runtime scheduler lock or submitting an execution.
  std::vector<ProfileEvent> expanded;
  uint64_t dropped = dropped_events_;
  auto append = [&](ProfileEvent event) {
    if (events_.size() + expanded.size() >= max_events_) {
      ++dropped;
      return;
    }
    if (stopped_ns_ && (!event.end_ns || event.end_ns > stopped_ns_)) {
      event.end_ns = std::max(stopped_ns_, event.start_ns);
      event.incomplete = true;
    }
    expanded.push_back(std::move(event));
  };
  for (const auto& batch : deferred_) {
    for (const auto& activity : *batch.activities) {
      ProfileEvent event = batch.event;
      event.name = activity.name;
      event.track = activity.track;
      event.start_ns += activity.start_ns;
      event.end_ns = batch.event.start_ns + activity.end_ns;
      if (!activity.detail.empty()) event.detail = activity.detail;
      event.hlo_text = activity.hlo_text;
      event.tf_op = activity.tf_op;
      event.source = activity.source;
      event.sparse_core = activity.sparse_core;
      event.bytes = activity.bytes;
      if (!activity.cost_gap.empty()) event.cost_gap = activity.cost_gap;
      append(event);
      if (activity.track == "Sparse Core Ops") {
        event.name = batch.event.name;
        event.track = "Sparse Core Modules";
        event.bytes = -1;
        event.hlo_text.clear();
        event.tf_op.clear();
        event.source.clear();
        append(std::move(event));
      }
    }
  }
  tensorflow::profiler::XSpace space;
  // Serialize chronologically. Async intervals need independent lanes: XPlane
  // lines represent stacks, so crossing intervals must never share a line.
  std::vector<const ProfileEvent*> ordered;
  for (const auto& event : events_) {
    if (!stopped_ns_ || event.start_ns <= stopped_ns_)
      ordered.push_back(&event);
  }
  for (const auto& event : expanded) {
    if (!stopped_ns_ || event.start_ns <= stopped_ns_)
      ordered.push_back(&event);
  }
  std::stable_sort(ordered.begin(), ordered.end(),
                   [](auto a, auto b) {
                     if (a->start_ns != b->start_ns) return a->start_ns < b->start_ns;
                     return a->end_ns > b->end_ns;
                   });
  using Track = std::pair<int64_t, std::string>;
  std::map<Track, std::vector<std::pair<int64_t, int64_t>>> lanes;
  std::map<int64_t, int64_t> next_line;
  std::map<int64_t, std::unique_ptr<tsl::profiler::XPlaneBuilder>> builders;
  std::map<std::pair<int64_t, int64_t>, int64_t> sparse_planes;
  int64_t next_plane = 2;
  for (const auto* event : ordered) {
    if (event->simulated) next_plane = std::max(next_plane, 3 + event->device_id);
    if (event->simulated && event->sparse_core >= 0)
      sparse_planes[{event->device_id, event->sparse_core}] = 0;
  }
  for (auto& [key, id] : sparse_planes) id = next_plane++;
  for (const ProfileEvent* pointer : ordered) {
    const ProfileEvent& event = *pointer;
    const bool device = event.simulated;
    const bool asynchronous = event.pending || !event.track.empty();
    // Native Trace Viewer reserves device IDs 1..500. CUSTOM IDs cannot be reused.
    const int64_t plane_id = !device ? 0 : event.sparse_core < 0
        ? 2 + event.device_id : sparse_planes.at({event.device_id, event.sparse_core});
    tensorflow::profiler::XPlane* plane = nullptr;
    for (auto& candidate : *space.mutable_planes()) {
      if (candidate.id() == plane_id) plane = &candidate;
    }
    if (!plane) {
      plane = space.add_planes();
      plane->set_id(plane_id);
      plane->set_name(device ? absl::StrCat("/device:TPU:", event.device_id)
                            : "/host:CPU");
      if (device && event.sparse_core >= 0)
        plane->set_name(absl::StrCat(plane->name(), " SparseCore ", event.sparse_core));
    }
    auto& cached_builder = builders[plane_id];
    if (!cached_builder)
      cached_builder = std::make_unique<tsl::profiler::XPlaneBuilder>(plane);
    auto& builder = *cached_builder;
    const std::string track = device ? event.track
        : asynchronous ? absl::StrCat("PJRT completion / device ", event.device_id,
                                      " / ", event.track.empty() ? event.name : event.track)
                       : absl::StrCat("thread ", event.thread_id);
    auto& available = lanes[{plane_id, track}];
    size_t lane = 0;
    if (asynchronous) {
      while (lane < available.size() && available[lane].second > event.start_ns)
        ++lane;
    }
    if (lane == available.size()) {
      // Match TPU's native line IDs. Extra overlapping lanes use a separate range.
      int64_t id = next_line[plane_id]++ + (device ? 100 : (int64_t{1} << 31));
      if (!device && !asynchronous) id = event.thread_id;
      if (device && lane == 0) {
        if (track == "XLA Modules") id = 2;
        if (track == "XLA Ops") id = 3;
        if (track == "XLA TraceMe") id = 7;
        if (track == "Sparse Core Modules") id = 66;
        if (track == "Sparse Core Ops") id = 67;
        if (track == "SparseCore Offload Type") id = 145;
      }
      available.push_back({id, 0});
    }
    available[lane].second = event.end_ns;
    auto line = builder.GetOrCreateLine(available[lane].first);
    line.SetTimestampNs(start_ns_);
    if (!device && !asynchronous) {
      if (!event.thread_name.empty()) line.SetName(event.thread_name);
    } else {
      line.SetName(lane ? absl::StrCat(track, " [", lane + 1, "]") : track);
    }
    auto* metadata = builder.GetOrCreateEventMetadata(
        device ? absl::StrCat(event.program_id, ":", track, ":", event.name)
               : event.name);
    metadata->set_name(event.hlo_text.empty() ? event.name : event.hlo_text);
    metadata->set_display_name(event.name);
    auto out = line.AddEvent(*metadata);
    if (!event.tf_op.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("tf_op"), event.tf_op);
    if (!event.source.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("source"), event.source);
    if (device && (track == "XLA Modules" || track == "Sparse Core Modules"))
      out.AddStatValue(*builder.GetOrCreateStatMetadata("hlo_module"), event.name);
    if (device && (track == "XLA Ops" || track == "Sparse Core Ops"))
      out.AddStatValue(*builder.GetOrCreateStatMetadata("hlo_op"), event.name);
    out.SetTimestampNs(event.start_ns);
    out.SetDurationNs(std::max<int64_t>(0, event.end_ns - event.start_ns));
    out.AddStatValue(*builder.GetOrCreateStatMetadata("clock_domain"),
                     event.simulated ? "simulated" : "cpu_wall");
    if (!event.track.empty()) {
      out.AddStatValue(*builder.GetOrCreateStatMetadata("clock_alignment"),
                       "runtime_realtime");
      out.AddStatValue(*builder.GetOrCreateStatMetadata("device"),
                       event.device_id);
      if (event.sparse_core >= 0)
        out.AddStatValue(*builder.GetOrCreateStatMetadata("sparse_core"), event.sparse_core);
      if (!event.cost_gap.empty())
        out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_gap"),
                         event.cost_gap);
      out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_status"),
                       !event.simulated          ? "observed"
                       : !event.cost_gap.empty() ? "partial"
                       : event.track == "Launch" ? "structural"
                                                 : "estimated");
      out.AddStatValue(*builder.GetOrCreateStatMetadata("annotation_kind"),
                       event.track == "XLA Modules" ? "executable_scope"
                       : event.track == "XLA Ops" ? "compilation_scope"
                       : event.track == "Unresolved" ? "unresolved_cost"
                                                      : "activity");
    }
    out.AddStatValue(*builder.GetOrCreateStatMetadata("correlation_id"),
                     event.correlation_id);
    if (event.program_id) {
      out.AddStatValue(*builder.GetOrCreateStatMetadata("program_id"),
                       event.program_id);
      // XProf consumes the standard program_id internally. Keep a custom
      // alias so Trace Viewer also exposes it for host/device correlation.
      out.AddStatValue(*builder.GetOrCreateStatMetadata("sim_program_id"),
                       event.program_id);
      out.AddStatValue(*builder.GetOrCreateStatMetadata("num_devices"),
                       event.num_devices);
      out.AddStatValue(*builder.GetOrCreateStatMetadata("num_replicas"),
                       event.num_replicas);
    }
    out.AddStatValue(*builder.GetOrCreateStatMetadata("device_id"),
                     event.device_id);
    out.AddStatValue(*builder.GetOrCreateStatMetadata("incomplete"),
                     event.incomplete);
    if (event.buffer_id)
      out.AddStatValue(*builder.GetOrCreateStatMetadata("buffer_id"),
                       event.buffer_id);
    if (event.bytes >= 0)
      out.AddStatValue(*builder.GetOrCreateStatMetadata("bytes"), event.bytes);
    if (dropped)
      out.AddStatValue(*builder.GetOrCreateStatMetadata("dropped_events"),
                       dropped);
    if (!event.detail.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("detail"),
                       event.detail);
    if (!event.input_buffers.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("input_buffers"),
                       event.input_buffers);
    if (!event.output_buffers.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("output_buffers"),
                       event.output_buffers);
    if (!event.error.empty())
      out.AddStatValue(*builder.GetOrCreateStatMetadata("error"), event.error);
  }
  for (auto& plane : *space.mutable_planes()) {
    tsl::profiler::XPlaneBuilder builder(&plane);
    builder.AddStatValue(*builder.GetOrCreateStatMetadata("dropped_events"),
                         dropped);
  }
  if (dropped)
    space.add_warnings(
        absl::StrCat("PJRT simulator dropped ", dropped, " events"));
  return space.SerializeAsString();
}

absl::StatusOr<std::shared_ptr<ProfileSession>> StartProfile() {
  std::lock_guard<std::mutex> lock(session_mutex);
  if (std::atomic_load(&active_session)) {
    return absl::AlreadyExistsError("A simulator profile is already active");
  }
  auto session = std::make_shared<ProfileSession>();
  std::atomic_store(&active_session, session);
  return session;
}

void StopProfile(const std::shared_ptr<ProfileSession>& session) {
  if (!session) return;
  std::lock_guard<std::mutex> lock(session_mutex);
  session->Stop();
  if (std::atomic_load(&active_session) == session) {
    std::atomic_store(&active_session, std::shared_ptr<ProfileSession>());
  }
}

ProfileCall::ProfileCall(const char* name, absl::string_view detail,
                         const ProfileActivity* parent) {
  activity_.session_ = parent ? parent->session_ : std::atomic_load(&active_session);
  if (!activity_.session_) return;
  ProfileEvent& event = activity_.event_;
  event.name = name;
  event.detail = std::string(detail);
  event.start_ns = Now();
  event.thread_id = tsl::Env::Default()->GetCurrentThreadId();
  tsl::Env::Default()->GetCurrentThreadName(&event.thread_name);
  event.correlation_id = parent ? parent->correlation_id()
      : next_correlation.fetch_add(1, std::memory_order_relaxed);
  activity_.index_ = activity_.session_->Begin(
      event, parent ? parent->index_ : kDropped);
}

void ProfileActivity::Finish(const absl::Status& status) const {
  if (session_) session_->Finish(index_, status);
}

void ProfileActivity::SetBuffer(uint64_t id, int64_t bytes,
                                int64_t device) const {
  if (session_) session_->SetBuffer(index_, id, bytes, device);
}

void ProfileSession::SetProgram(size_t index, uint64_t id, int64_t devices,
                                int64_t replicas) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (stopped_ || index >= events_.size()) return;
  events_[index].program_id = id;
  events_[index].num_devices = devices;
  events_[index].num_replicas = replicas;
}

void ProfileActivity::SetProgram(uint64_t id, int64_t devices,
                                 int64_t replicas) const {
  if (session_) session_->SetProgram(index_, id, devices, replicas);
}

void ProfileActivity::SetLinks(std::string inputs, std::string outputs) const {
  if (session_)
    session_->SetLinks(index_, std::move(inputs), std::move(outputs));
}

void ProfileActivity::Ready(const Future<>& future, const char* name,
                            int64_t device, uint64_t buffer_id,
                            int64_t bytes) const {
  if (!session_) return;
  ProfileEvent event = event_;
  event.name = name;
  event.pending = true;
  event.device_id = device;
  event.buffer_id = buffer_id;
  event.bytes = bytes;
  size_t index = session_->Begin(std::move(event), index_);
  future.OnReady([session = session_, index](absl::Status status) {
    session->Finish(index, status);
  });
}

void ProfileActivity::Activities(
    const std::string& name, int64_t start, int64_t device, bool partial,
    std::shared_ptr<const std::vector<BundleActivity>> activities) const {
  if (!session_) return;
  ProfileEvent event = event_;
  event.name = name;
  event.start_ns = start;
  event.device_id = device;
  event.simulated = true;
  if (partial) event.cost_gap = "partial bundle cost coverage";
  session_->DeferActivities(std::move(event), index_, std::move(activities));
}

void ProfileActivity::Interval(const std::string& name, int64_t start,
                               int64_t end, int64_t device,
                               const std::string& track,
                               const std::string& cost_gap,
                               int64_t bytes, const std::string& detail,
                               const std::string& hlo_text,
                               const std::string& tf_op,
                               const std::string& source, int64_t sparse_core) const {
  if (!session_) return;
  ProfileEvent event = event_;
  event.name = name;
  event.start_ns = start;
  event.end_ns = end;
  event.device_id = device;
  event.track = track;
  if (!detail.empty()) event.detail = detail;
  event.hlo_text = hlo_text;
  event.tf_op = tf_op;
  event.source = source;
  event.sparse_core = sparse_core;
  event.cost_gap = cost_gap;
  event.bytes = bytes;
  event.simulated = true;
  session_->Begin(std::move(event), index_);
}

}  // namespace xla::sim
