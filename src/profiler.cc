/* Copyright 2026 The OpenXLA Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/
#include "src/profiler.h"

#include <algorithm>
#include <atomic>
#include <limits>
#include <utility>

#include "absl/strings/str_cat.h"
#include "xla/tsl/profiler/utils/xplane_builder.h"
#include "tsl/platform/env.h"
#include "tsl/profiler/protobuf/xplane.pb.h"

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
  // CUSTOM planes are visible in Trace Viewer without claiming TPU counters.
  // Plane 0 is host API calls; plane d+1 is pending activity targeting device
  // d.
  for (const ProfileEvent& event : events_) {
    if (stopped_ns_ && event.start_ns > stopped_ns_) continue;
    const int64_t plane_id = !event.track.empty() ? 1000 + event.device_id
                             : event.pending      ? event.device_id + 2
                                                  : 0;
    tensorflow::profiler::XPlane* plane = nullptr;
    for (auto& candidate : *space.mutable_planes()) {
      if (candidate.id() == plane_id) plane = &candidate;
    }
    if (!plane) {
      plane = space.add_planes();
      plane->set_id(plane_id);
      plane->set_name(absl::StrCat("/device:CUSTOM:", plane_id,
                                   !event.track.empty() ? " Simulated TPU"
                                   : event.pending
                                       ? " PJRT pending (CPU wall time)"
                                       : " PJRT host (CPU wall time)"));
    }
    tsl::profiler::XPlaneBuilder builder(plane);
    int64_t line_id = event.thread_id;
    if (!event.track.empty()) {
      const std::vector<std::string> tracks = {"Executions",
                                               "Launch",
                                               "HLO",
                                               "DMA",
                                               "Communication",
                                               "CPU readiness",
                                               "Runtime notification"};
      line_id =
          std::find(tracks.begin(), tracks.end(), event.track) - tracks.begin();
    }
    auto line = builder.GetOrCreateLine(line_id);
    line.SetTimestampNs(start_ns_);
    line.SetName(!event.track.empty()
                     ? event.track
                     : absl::StrCat(event.pending ? "submit-to-ready; thread "
                                                  : "thread ",
                                    event.thread_id));
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
      out.AddStatValue(*builder.GetOrCreateStatMetadata("framework_op"),
                       event.framework_op);
      out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_gap"),
                       event.cost_gap);
      if (!event.cost_source.empty()) {
        out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_source"),
                         event.cost_source);
        out.AddStatValue(*builder.GetOrCreateStatMetadata("kernel_flops"),
                         event.flops);
        out.AddStatValue(*builder.GetOrCreateStatMetadata("transcendentals"),
                         event.transcendentals);
      }
      if (event.track == "HLO" && !event.cost_gap.empty()) {
        out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_status"),
                         "unknown");
        out.AddStatValue(*builder.GetOrCreateStatMetadata("logical_bytes"),
                         "null");
        out.AddStatValue(*builder.GetOrCreateStatMetadata("dot_flops"), "null");
      } else {
        out.AddStatValue(*builder.GetOrCreateStatMetadata("cost_status"),
                         !event.cost_source.empty() || event.logical_bytes ||
                                 event.flops || event.transcendentals
                             ? "estimated"
                             : "structural");
        out.AddStatValue(*builder.GetOrCreateStatMetadata("logical_bytes"),
                         event.logical_bytes);
        out.AddStatValue(*builder.GetOrCreateStatMetadata("dot_flops"),
                         event.cost_source.empty() ? event.flops : 0.0);
      }
      if (event.track == "Executions")
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

ProfileActivity ProfileActivity::Child(const char* name) const {
  ProfileActivity child;
  if (!session_) return child;
  child.session_ = session_;
  child.event_ = event_;
  child.event_.name = name;
  child.event_.start_ns = Now();
  child.event_.thread_id = tsl::Env::Default()->GetCurrentThreadId();
  child.index_ = session_->Begin(child.event_);
  return child;
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
                               const std::string& framework_op,
                               const std::string& cost_gap, double bytes,
                               double flops, double transcendentals,
                               const std::string& cost_source) const {
  if (!session_) return;
  ProfileEvent event = event_;
  event.name = name;
  event.start_ns = start;
  event.end_ns = end;
  event.device_id = device;
  event.track = track;
  event.framework_op = framework_op;
  event.cost_gap = cost_gap;
  event.logical_bytes = bytes;
  event.flops = flops;
  event.transcendentals = transcendentals;
  event.cost_source = cost_source;
  event.simulated = track != "CPU readiness" && track != "Runtime notification";
  session_->Begin(std::move(event), index_);
}

}  // namespace xla::sim
