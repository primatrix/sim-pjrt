// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#ifndef XLA_PJRT_SIM_RUNTIME_H_
#define XLA_PJRT_SIM_RUNTIME_H_

#include <condition_variable>
#include <cstdint>
#include <map>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <thread>
#include <vector>

#include "absl/status/statusor.h"
#include "xla/future.h"
#include "src/execution_plan.h"
#include "src/profiler.h"

namespace xla::sim {

struct RuntimeConfig {
  // Opt-in per-array host storage limit; zero preserves CPU storage.
  int64_t max_materialized_bytes = 0;
  // Hypothetical per-chiplet rates, not calibrated TPU measurements.
  double flops_per_second = 1.1535e15;
  double transcendentals_per_second = 1e12;
  double hbm_bytes_per_second = 3.69e12;
  double host_bytes_per_second = 32e9;
  double link_bytes_per_second = 100e9;
  int64_t launch_ns = 1000;
  int64_t transfer_ns = 2000;
  int64_t link_ns = 1000;
  double compute_scale = 1;
  double communication_scale = 1;
  static absl::StatusOr<RuntimeConfig> FromEnvironment();
};

// Modeled completion and host-observable readiness are deliberately separate:
// the latter also requires the CPU functional backend to have produced data.
struct Completion {
  int64_t end_ns = 0;  // steady clock nanoseconds
  Future<> future = Future<>(absl::OkStatus());
};

class SimRuntime {
 public:
  explicit SimRuntime(RuntimeConfig config);
  int64_t max_materialized_bytes() const {
    return config_.max_materialized_bytes;
  }
  ~SimRuntime();
  SimRuntime(const SimRuntime&) = delete;
  SimRuntime& operator=(const SimRuntime&) = delete;

  std::vector<Completion> Execute(const ExecutionPlan& plan,
                                  const std::vector<int64_t>& devices,
                                  const std::vector<Completion>& inputs,
                                  const ProfileActivity& profile,
                                  const std::string& name);
  Completion Transfer(int64_t source, int64_t destination, int64_t bytes,
                      const Completion& input, const ProfileActivity& profile);
  Future<> WithCpu(const Completion& completion, Future<> cpu,
                   const ProfileActivity& profile, int64_t device) const;

 private:
  struct Timer {
    int64_t deadline;
    uint64_t sequence;
    std::shared_ptr<Promise<>> promise;
    bool operator<(const Timer& other) const {
      return deadline != other.deadline ? deadline > other.deadline
                                        : sequence > other.sequence;
    }
  };
  Completion CompleteAt(int64_t end);
  void Run();
  int64_t Reserve(int64_t start, int64_t duration,
                  const std::vector<std::string>& resources);
  int64_t Epoch(int64_t steady_ns) const { return steady_ns + epoch_offset_; }

  const RuntimeConfig config_;
  const int64_t epoch_offset_;
  std::mutex mutex_;
  std::condition_variable changed_;
  bool stopping_ = false;
  uint64_t sequence_ = 0;
  std::map<std::string, int64_t> resources_;
  std::map<int64_t, Completion> execution_tail_;
  std::priority_queue<Timer> timers_;
  std::thread worker_;
};

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_RUNTIME_H_
