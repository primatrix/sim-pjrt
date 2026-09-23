// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "xla/pjrt/sim/runtime.h"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/numbers.h"
#include "absl/strings/str_cat.h"
#include "tsl/platform/env.h"

namespace xla::sim {
namespace {
using Clock = std::chrono::steady_clock;
int64_t Now() {
  return std::chrono::duration_cast<std::chrono::nanoseconds>(
             Clock::now().time_since_epoch())
      .count();
}
int64_t Duration(double seconds) {
  // Bound pathological shapes/configurations before converting to integer ns.
  return static_cast<int64_t>(std::ceil(std::min(seconds, 86400.0) * 1e9));
}
absl::Status ReadScale(const char* name, double& value) {
  const char* text = std::getenv(name);
  if (text && (!absl::SimpleAtod(text, &value) || !std::isfinite(value) ||
               value <= 0 || value > 1e6))
    return absl::InvalidArgumentError(
        absl::StrCat(name, " must be in (0, 1000000]"));
  return absl::OkStatus();
}
absl::Status ReadLatency(const char* name, int64_t& value) {
  const char* text = std::getenv(name);
  if (text &&
      (!absl::SimpleAtoi(text, &value) || value < 0 || value > 1000000000))
    return absl::InvalidArgumentError(
        absl::StrCat(name, " must be in [0, 1000000000] ns"));
  return absl::OkStatus();
}
absl::Status ReadRate(const char* name, double& value) {
  const char* text = std::getenv(name);
  if (text && (!absl::SimpleAtod(text, &value) || !std::isfinite(value) ||
               value <= 0 || value > 1e30))
    return absl::InvalidArgumentError(
        absl::StrCat(name, " must be in (0, 1e30]"));
  return absl::OkStatus();
}
}  // namespace

absl::StatusOr<RuntimeConfig> RuntimeConfig::FromEnvironment() {
  RuntimeConfig config;
  if (const char* value = std::getenv("PJRT_SIM_MAX_MATERIALIZED_BYTES")) {
    if (!absl::SimpleAtoi(value, &config.max_materialized_bytes) ||
        (config.max_materialized_bytes != 0 &&
         config.max_materialized_bytes < 16)) {
      return absl::InvalidArgumentError(
          "PJRT_SIM_MAX_MATERIALIZED_BYTES must be 0 (disabled) or at least 16 "
          "bytes");
    }
  }
  ABSL_RETURN_IF_ERROR(
      ReadScale("PJRT_SIM_COMPUTE_SCALE", config.compute_scale));
  ABSL_RETURN_IF_ERROR(
      ReadScale("PJRT_SIM_COMMUNICATION_SCALE", config.communication_scale));
  ABSL_RETURN_IF_ERROR(ReadLatency("PJRT_SIM_LAUNCH_NS", config.launch_ns));
  ABSL_RETURN_IF_ERROR(ReadLatency("PJRT_SIM_TRANSFER_NS", config.transfer_ns));
  ABSL_RETURN_IF_ERROR(ReadLatency("PJRT_SIM_LINK_NS", config.link_ns));
  ABSL_RETURN_IF_ERROR(
      ReadRate("PJRT_SIM_FLOPS_PER_SECOND", config.flops_per_second));
  ABSL_RETURN_IF_ERROR(ReadRate("PJRT_SIM_TRANSCENDENTALS_PER_SECOND",
                                config.transcendentals_per_second));
  ABSL_RETURN_IF_ERROR(
      ReadRate("PJRT_SIM_HBM_BYTES_PER_SECOND", config.hbm_bytes_per_second));
  ABSL_RETURN_IF_ERROR(
      ReadRate("PJRT_SIM_HOST_BYTES_PER_SECOND", config.host_bytes_per_second));
  ABSL_RETURN_IF_ERROR(
      ReadRate("PJRT_SIM_LINK_BYTES_PER_SECOND", config.link_bytes_per_second));
  return config;
}

SimRuntime::SimRuntime(RuntimeConfig config)
    : config_(config),
      epoch_offset_(tsl::Env::Default()->NowNanos() - Now()),
      worker_([this] { Run(); }) {}

SimRuntime::~SimRuntime() {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    stopping_ = true;
  }
  changed_.notify_one();
  worker_.join();
}

void SimRuntime::Run() {
  std::unique_lock<std::mutex> lock(mutex_);
  while (!stopping_ || !timers_.empty()) {
    if (timers_.empty()) {
      changed_.wait(lock);
      continue;
    }
    const Timer timer = timers_.top();
    if (!stopping_ && timer.deadline > Now()) {
      changed_.wait_until(
          lock, Clock::time_point(std::chrono::nanoseconds(timer.deadline)));
      continue;
    }
    timers_.pop();
    const absl::Status status =
        stopping_ ? absl::CancelledError("Simulator client destroyed")
                  : absl::OkStatus();
    lock.unlock();
    // PJRT callbacks can reenter the runtime or wait for other events. Never
    // execute them under the scheduler lock or on the deadline worker.
    tsl::Env::Default()->SchedClosure(
        [promise = timer.promise, status]() { promise->Set(status); });
    lock.lock();
  }
}

Completion SimRuntime::CompleteAt(int64_t end) {
  auto [promise, future] = MakePromise();
  timers_.push(
      Timer{end, sequence_++, std::make_shared<Promise<>>(std::move(promise))});
  changed_.notify_one();
  return Completion{end, std::move(future)};
}

int64_t SimRuntime::Reserve(int64_t start, int64_t duration,
                            const std::vector<std::string>& resources) {
  if (!duration) return start;
  for (const std::string& resource : resources)
    start = std::max(start, resources_[resource]);
  for (const std::string& resource : resources)
    resources_[resource] = start + duration;
  return start;
}

std::vector<Completion> SimRuntime::Execute(
    const ExecutionPlan& plan, const std::vector<int64_t>& devices,
    const std::vector<Completion>& inputs, const ProfileActivity& profile,
    const std::string& name) {
  std::lock_guard<std::mutex> lock(mutex_);
  int64_t release = Now();
  for (const Completion& input : inputs)
    release = std::max(release, input.end_ns);
  std::vector<int64_t> starts, launch;
  std::vector<Future<>> predecessors;
  for (const Completion& input : inputs) predecessors.push_back(input.future);
  for (int64_t device : devices) {
    const int64_t start = std::max(release, execution_tail_[device].end_ns);
    predecessors.push_back(execution_tail_[device].future);
    starts.push_back(start);
    launch.push_back(start + config_.launch_ns);
    profile.Interval("device launch", Epoch(start), Epoch(launch.back()),
                     device, "Launch");
  }
  std::vector<std::vector<int64_t>> ends;
  for (const PlanNode& node : plan.nodes) {
    std::vector<int64_t> ready = launch;
    for (int dependency : node.dependencies)
      for (int d = 0; d < devices.size(); ++d)
        ready[d] = std::max(ready[d], ends[dependency][d]);
    if (node.kind == PlanNode::Kind::kTransfers) {
      // Conservative group barrier over directed logical links. This models
      // payload movement, not a calibrated physical TPU routing algorithm.
      const int64_t release = *std::max_element(ready.begin(), ready.end());
      int64_t end = release;
      const int64_t duration = Duration(
          config_.communication_scale *
          (config_.link_ns / 1e9 + node.bytes / config_.link_bytes_per_second));
      for (const auto& [source, target] : node.transfers) {
        const int64_t src = devices[source], dst = devices[target];
        const int64_t start =
            Reserve(release, duration, {absl::StrCat("link:", src, ":", dst)});
        end = std::max(end, start + duration);
        profile.Interval(node.name, Epoch(start), Epoch(start + duration), src,
                         "Communication", node.framework_op, {}, node.bytes);
      }
      std::fill(ready.begin(), ready.end(), end);
    } else if ((node.kind == PlanNode::Kind::kAllReduce ||
                node.kind == PlanNode::Kind::kAllGather ||
                node.kind == PlanNode::Kind::kReduceScatter) &&
               devices.size() > 1) {
      // Declared synthetic directed ring; no claim about a physical v7x slice.
      const int count = devices.size();
      int64_t round_start = *std::max_element(ready.begin(), ready.end());
      const double chunk = node.kind == PlanNode::Kind::kAllGather
                               ? node.bytes
                               : std::ceil(node.bytes / count);
      const int rounds =
          (count - 1) * (node.kind == PlanNode::Kind::kAllReduce ? 2 : 1);
      const int64_t duration = Duration(
          config_.communication_scale *
          (config_.link_ns / 1e9 + chunk / config_.link_bytes_per_second));
      for (int round = 0; round < rounds; ++round) {
        int64_t round_end = round_start;
        for (int d = 0; d < count; ++d) {
          const int64_t src = devices[d], dst = devices[(d + 1) % count];
          const int64_t start = Reserve(round_start, duration,
                                        {absl::StrCat("link:", src, ":", dst)});
          round_end = std::max(round_end, start + duration);
          profile.Interval(node.name, Epoch(start), Epoch(start + duration),
                           src, "Communication", node.framework_op, {}, chunk);
        }
        round_start = round_end;
      }
      std::fill(ready.begin(), ready.end(), round_start);
    } else {
      const int64_t duration =
          node.kind != PlanNode::Kind::kCompute
              ? 0
              : Duration(config_.compute_scale *
                         std::max({node.flops / config_.flops_per_second,
                                   node.transcendentals /
                                       config_.transcendentals_per_second,
                                   node.bytes / config_.hbm_bytes_per_second}));
      for (int d = 0; d < devices.size(); ++d) {
        const int64_t device = devices[d];
        const int64_t start = Reserve(
            ready[d], duration,
            {absl::StrCat("compute:", device), absl::StrCat("hbm:", device)});
        ready[d] = start + duration;
        profile.Interval(node.name, Epoch(start), Epoch(ready[d]), device,
                         "HLO", node.framework_op, node.cost_gap, node.bytes,
                         node.flops, node.transcendentals, node.cost_source);
      }
    }
    ends.push_back(std::move(ready));
  }
  std::vector<Completion> result;
  for (int d = 0; d < devices.size(); ++d) {
    const int64_t end = plan.root < 0 ? launch[d] : ends[plan.root][d];
    profile.Interval(name, Epoch(starts[d]), Epoch(end), devices[d],
                     "Executions", {},
                     plan.cost_gaps ? "partial HLO cost coverage" : "");
    Completion completion = CompleteAt(end);
    std::vector<Future<>> waits = predecessors;
    waits.push_back(completion.future);
    completion.future = JoinFutures(waits);
    execution_tail_[devices[d]] = completion;
    result.push_back(std::move(completion));
  }
  return result;
}

Completion SimRuntime::Transfer(int64_t source, int64_t destination,
                                int64_t bytes, const Completion& input,
                                const ProfileActivity& profile) {
  std::lock_guard<std::mutex> lock(mutex_);
  const bool host = source < 0 || destination < 0;
  const int64_t device = destination < 0 ? source : destination;
  const int64_t duration =
      Duration(config_.communication_scale *
               ((host ? config_.transfer_ns : config_.link_ns) / 1e9 +
                bytes / (host ? config_.host_bytes_per_second
                              : config_.link_bytes_per_second)));
  std::vector<std::string> resources = {
      absl::StrCat("link:", source, ":", destination)};
  if (source >= 0) resources.push_back(absl::StrCat("hbm:", source));
  if (destination >= 0) resources.push_back(absl::StrCat("hbm:", destination));
  const int64_t start =
      Reserve(std::max(Now(), input.end_ns), duration, resources);
  profile.Interval(source < 0        ? "H2D"
                   : destination < 0 ? "D2H"
                                     : "Device copy",
                   Epoch(start), Epoch(start + duration), device, "DMA", {}, {},
                   bytes);
  Completion completion = CompleteAt(start + duration);
  completion.future = JoinFutures({input.future, completion.future});
  return completion;
}

Future<> SimRuntime::WithCpu(const Completion& completion, Future<> cpu,
                             const ProfileActivity& profile,
                             int64_t device) const {
  const int64_t end = Epoch(completion.end_ns);
  if (profile) {
    cpu.OnReady([profile, device, end](absl::Status status) {
      const int64_t now = tsl::Env::Default()->NowNanos();
      if (now > end)
        profile.Interval("CPU readiness observation lag", end, now, device,
                         "CPU readiness", {},
                         status.ok() ? "" : status.ToString());
    });
    completion.future.OnReady([profile, device, end](absl::Status status) {
      const int64_t now = tsl::Env::Default()->NowNanos();
      if (now > end)
        profile.Interval("Runtime notification lag", end, now, device,
                         "Runtime notification", {},
                         status.ok() ? "" : status.ToString());
    });
  }
  return JoinFutures({completion.future, std::move(cpu)});
}

}  // namespace xla::sim
