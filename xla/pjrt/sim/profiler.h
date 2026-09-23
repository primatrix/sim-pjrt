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
#ifndef XLA_PJRT_SIM_PROFILER_H_
#define XLA_PJRT_SIM_PROFILER_H_

#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "absl/status/status.h"
#include "absl/status/statusor.h"
#include "absl/strings/string_view.h"
#include "xla/future.h"
#include "xla/pjrt/c/pjrt_c_api_profiler_extension.h"

namespace xla::sim {

// Host observations and runtime reservations use a shared epoch. Pending host
// intervals include submission, queuing and completion notification overhead.
struct ProfileEvent {
  std::string name;
  std::string detail;
  std::string input_buffers;
  std::string output_buffers;
  int64_t start_ns = 0;
  int64_t end_ns = 0;
  int64_t thread_id = 0;
  int64_t device_id = -1;
  uint64_t correlation_id = 0;
  uint64_t buffer_id = 0;
  uint64_t program_id = 0;
  int64_t num_devices = 0;
  int64_t num_replicas = 1;
  int64_t bytes = -1;
  bool pending = false;
  bool incomplete = false;
  std::string error;
  std::string track;
  std::string framework_op;
  std::string cost_gap;
  double flops = 0;
  double logical_bytes = 0;
  double transcendentals = 0;
  std::string cost_source;
  bool simulated = false;
};

// A session owns its events even when callbacks outlive Stop or destruction of
// the C API profiler handle. A stopped session never accepts late events.
class ProfileSession {
 public:
  explicit ProfileSession(size_t max_events = 1000000);
  size_t Begin(ProfileEvent event, size_t parent = static_cast<size_t>(-1));
  void Finish(size_t index, const absl::Status& status);
  void SetBuffer(size_t index, uint64_t id, int64_t bytes, int64_t device);
  void SetLinks(size_t index, std::string inputs, std::string outputs);
  void SetProgram(size_t index, uint64_t id, int64_t devices, int64_t replicas);
  void Stop();
  std::string Serialize() const;

 private:
  mutable std::mutex mutex_;
  const size_t max_events_;
  const int64_t start_ns_;
  bool stopped_ = false;
  int64_t stopped_ns_ = 0;
  uint64_t dropped_events_ = 0;
  std::vector<ProfileEvent> events_;
};

absl::StatusOr<std::shared_ptr<ProfileSession>> StartProfile();
void StopProfile(const std::shared_ptr<ProfileSession>& session);

class ProfileActivity {
 public:
  ProfileActivity() = default;
  void Finish(const absl::Status& status = absl::OkStatus()) const;
  void SetBuffer(uint64_t id, int64_t bytes, int64_t device) const;
  void SetLinks(std::string inputs, std::string outputs) const;
  void SetProgram(uint64_t id, int64_t devices, int64_t replicas) const;
  ProfileActivity Child(const char* name) const;
  void Ready(const Future<>& future, const char* name, int64_t device = -1,
             uint64_t buffer_id = 0, int64_t bytes = -1) const;
  explicit operator bool() const { return session_ != nullptr; }
  // Runtime reservations in epoch ns; Stop clips or discards future work.
  void Interval(const std::string& name, int64_t start, int64_t end,
                int64_t device, const std::string& track,
                const std::string& framework_op = {},
                const std::string& cost_gap = {}, double bytes = 0,
                double flops = 0, double transcendentals = 0,
                const std::string& cost_source = {}) const;
  uint64_t correlation_id() const { return event_.correlation_id; }

 private:
  friend class ProfileCall;
  std::shared_ptr<ProfileSession> session_;
  size_t index_ = 0;
  ProfileEvent event_;
};

// Disabled profiling takes only an atomic shared_ptr load. No event names,
// timestamps, callback registrations or serialized records are built then.
class ProfileCall {
 public:
  explicit ProfileCall(const char* name, absl::string_view detail = {});
  ~ProfileCall() { activity_.Finish(); }
  ProfileCall(const ProfileCall&) = delete;
  ProfileCall& operator=(const ProfileCall&) = delete;
  const ProfileActivity& activity() const { return activity_; }

 private:
  ProfileActivity activity_;
};

PJRT_Profiler_Extension* ProfilerExtension();

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_PROFILER_H_
