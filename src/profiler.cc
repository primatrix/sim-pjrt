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
  if (events_.size() == max_events_) {
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
  tensorflow::profiler::XSpace space;
  // Serialize chronologically. Async intervals need independent lanes: XPlane
  // lines represent stacks, so crossing intervals must never share a line.
  std::vector<const ProfileEvent*> ordered;
  for (const auto& event : events_) {
    if (!stopped_ns_ || event.start_ns <= stopped_ns_)
      ordered.push_back(&event);
  }
  std::stable_sort(ordered.begin(), ordered.end(),
                   [](auto a, auto b) { return a->start_ns < b->start_ns; });
  using Track = std::pair<int64_t, std::string>;
  std::map<Track, std::vector<std::pair<int64_t, int64_t>>> lanes;
  std::map<int64_t, int64_t> next_line;
  for (const ProfileEvent* pointer : ordered) {
    const ProfileEvent& event = *pointer;
    const bool device = event.simulated;
    const bool asynchronous = event.pending || !event.track.empty();
    const int64_t plane_id = device         ? 1000 + event.device_id
                             : asynchronous ? 100 + event.device_id + 1
                                            : 0;
    tensorflow::profiler::XPlane* plane = nullptr;
    for (auto& candidate : *space.mutable_planes()) {
      if (candidate.id() == plane_id) plane = &candidate;
    }
    if (!plane) {
      plane = space.add_planes();
      plane->set_id(plane_id);
      plane->set_name(absl::StrCat(
          "/device:CUSTOM:", plane_id, " ",
          device ? absl::StrCat("Simulated TPU ", event.device_id)
          : asynchronous
              ? absl::StrCat("Host completion / device ", event.device_id)
              : "PJRT host API"));
    }
    tsl::profiler::XPlaneBuilder builder(plane);
    const std::string track = !event.track.empty() ? event.track
                              : event.pending
                                  ? event.name
                                  : absl::StrCat("thread ", event.thread_id);
    auto& available = lanes[{plane_id, track}];
    size_t lane = 0;
    if (asynchronous) {
      while (lane < available.size() && available[lane].second > event.start_ns)
        ++lane;
    }
    if (lane == available.size())
      available.push_back({next_line[plane_id]++, 0});
    available[lane].second = event.end_ns;
    auto line = builder.GetOrCreateLine(available[lane].first);
    line.SetTimestampNs(start_ns_);
    line.SetName(lane ? absl::StrCat(track, " [", lane + 1, "]") : track);
    auto out = line.AddEvent(*builder.GetOrCreateEventMetadata(event.name));
    out.SetTimestampNs(event.start_ns);
    out.SetDurationNs(std::max<int64_t>(0, event.end_ns - event.start_ns));
    out.AddStatValue(*builder.GetOrCreateStatMetadata("clock_domain"),
                     event.simulated ? "simulated" : "cpu_wall");
    if (!event.track.empty()) {
      out.AddStatValue(*builder.GetOrCreateStatMetadata("clock_alignment"),
                       "runtime_realtime");
      out.AddStatValue(*builder.GetOrCreateStatMetadata("device"),
                       event.device_id);
      if (!event.cost_gap.empty())
        out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_gap"),
                         event.cost_gap);
      out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_status"),
                       !event.simulated          ? "observed"
                       : !event.cost_gap.empty() ? "partial"
                       : event.track == "Launch" ? "structural"
                                                 : "estimated");
      if (event.track == "Bundles")
        out.AddStatValue(*builder.GetOrCreateStatMetadata("annotation_kind"),
                         "executable_scope");
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
    if (dropped_events_)
      out.AddStatValue(*builder.GetOrCreateStatMetadata("dropped_events"),
                       dropped_events_);
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
                         dropped_events_);
  }
  if (dropped_events_)
    space.add_warnings(
        absl::StrCat("PJRT simulator dropped ", dropped_events_, " events"));
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

ProfileCall::ProfileCall(const char* name, absl::string_view detail) {
  activity_.session_ = std::atomic_load(&active_session);
  if (!activity_.session_) return;
  ProfileEvent& event = activity_.event_;
  event.name = name;
  event.detail = std::string(detail);
  event.start_ns = Now();
  event.thread_id = tsl::Env::Default()->GetCurrentThreadId();
  event.correlation_id =
      next_correlation.fetch_add(1, std::memory_order_relaxed);
  activity_.index_ = activity_.session_->Begin(event);
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

void ProfileActivity::Interval(const std::string& name, int64_t start,
                               int64_t end, int64_t device,
                               const std::string& track,
                               const std::string& cost_gap,
                               int64_t bytes) const {
  if (!session_) return;
  ProfileEvent event = event_;
  event.name = name;
  event.start_ns = start;
  event.end_ns = end;
  event.device_id = device;
  event.track = track;
  event.cost_gap = cost_gap;
  event.bytes = bytes;
  event.simulated = true;
  session_->Begin(std::move(event), index_);
}

}  // namespace xla::sim
