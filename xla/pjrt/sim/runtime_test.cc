// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "xla/pjrt/sim/runtime.h"

#include <chrono>
#include <memory>

#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {

ExecutionPlan ComputePlan(double bytes) {
  ExecutionPlan plan;
  PlanNode node;
  node.kind = PlanNode::Kind::kCompute;
  node.bytes = bytes;
  plan.nodes.push_back(node);
  plan.root = 0;
  return plan;
}

TEST(RuntimeTest, CompletionIsDelayedWithoutProfilingAndDevicesCanOverlap) {
  RuntimeConfig config;
  config.launch_ns = 0;
  config.hbm_bytes_per_second = 1000;
  SimRuntime runtime(config);
  const auto started = std::chrono::steady_clock::now();
  auto first = runtime.Execute(ComputePlan(100), {0}, {}, {}, "first");
  auto other = runtime.Execute(ComputePlan(100), {1}, {}, {}, "other");
  auto next = runtime.Execute(ComputePlan(100), {0}, {}, {}, "next");
  EXPECT_FALSE(first[0].future.IsReady());
  EXPECT_EQ(next[0].end_ns - first[0].end_ns, 100000000);
  EXPECT_LT(other[0].end_ns, next[0].end_ns);
  EXPECT_OK(next[0].future.Await());
  EXPECT_GE(std::chrono::steady_clock::now() - started,
            std::chrono::milliseconds(200));
}

TEST(RuntimeTest, CopiesAndCollectivesRespectDependenciesAndCommunicationCost) {
  RuntimeConfig config;
  config.launch_ns = 0;
  config.transfer_ns = 50000000;
  config.link_ns = 10000000;
  SimRuntime runtime(config);
  Completion copy = runtime.Transfer(-1, 0, 0, {}, {});
  ExecutionPlan plan;
  PlanNode node;
  node.kind = PlanNode::Kind::kAllReduce;
  plan.nodes.push_back(node);
  plan.root = 0;
  auto outputs = runtime.Execute(plan, {0, 1}, {copy}, {}, "collective");
  EXPECT_EQ(outputs[0].end_ns, copy.end_ns + 20000000);
  EXPECT_EQ(outputs[0].end_ns, outputs[1].end_ns);
  Completion host = runtime.Transfer(0, -1, 0, outputs[0], {});
  EXPECT_EQ(host.end_ns, outputs[0].end_ns + 50000000);
  EXPECT_OK(host.future.Await());
}

TEST(RuntimeTest, CpuReadinessAndErrorsAreNotHiddenByModeledCompletion) {
  SimRuntime runtime(RuntimeConfig{});
  auto [promise, cpu] = MakePromise();
  Completion completed = runtime.Transfer(-1, 0, 0, {}, {});
  Future<> ready = runtime.WithCpu(completed, cpu, {}, 0);
  ASSERT_OK(completed.future.Await());
  EXPECT_FALSE(ready.IsReady());
  promise.Set(absl::InternalError("functional backend failure"));
  EXPECT_EQ(ready.Await().code(), absl::StatusCode::kInternal);
}

TEST(RuntimeTest, PallasTranscendentalsCanLimitCompletion) {
  RuntimeConfig config;
  config.launch_ns = 0;
  config.transcendentals_per_second = 1000;
  SimRuntime runtime(config);
  // The predecessor is in the future, so wall-clock submission jitter cannot
  // change the exact modeled difference checked below.
  ExecutionPlan plan = ComputePlan(0);
  plan.nodes[0].transcendentals = 100;
  auto first = runtime.Execute(plan, {0}, {}, {}, "attention");
  auto second = runtime.Execute(plan, {0}, first, {}, "attention");
  EXPECT_EQ(second[0].end_ns - first[0].end_ns, 100000000);
  EXPECT_OK(second[0].future.Await());
}

TEST(RuntimeTest, CallbackCanSubmitAndWaitWithoutBlockingTimerWorker) {
  SimRuntime runtime(RuntimeConfig{});
  auto [promise, done] = MakePromise();
  Completion first = runtime.Transfer(-1, 0, 0, {}, {});
  first.future.OnReady(
      [&runtime, promise = std::move(promise)](absl::Status status) mutable {
        Completion second = runtime.Transfer(-1, 1, 0, {}, {});
        promise.Set(second.future.Await());
      });
  EXPECT_OK(done.Await());
}

TEST(RuntimeTest, ClientDestructionCancelsOutstandingNotifications) {
  RuntimeConfig config;
  config.transfer_ns = 1000000000;
  auto runtime = std::make_unique<SimRuntime>(config);
  Completion transfer = runtime->Transfer(-1, 0, 0, {}, {});
  runtime.reset();
  EXPECT_EQ(transfer.future.Await().code(), absl::StatusCode::kCancelled);
}

TEST(RuntimeTest, DirectedTransfersBindPartitionOrdinalsToDevices) {
  RuntimeConfig config;
  config.launch_ns = 0;
  config.transfer_ns = 50000000;
  config.link_ns = 10000000;
  config.link_bytes_per_second = 1000;
  SimRuntime runtime(config);
  Completion input = runtime.Transfer(-1, 7, 0, {}, {});
  ExecutionPlan plan;
  PlanNode node;
  node.kind = PlanNode::Kind::kTransfers;
  node.transfers = {{0, 1}, {1, 0}};
  node.bytes = 10;
  plan.nodes.push_back(node);
  plan.root = 0;
  auto outputs = runtime.Execute(plan, {7, 3}, {input}, {}, "reshard");
  EXPECT_EQ(outputs[0].end_ns, input.end_ns + 20000000);
  EXPECT_EQ(outputs[0].end_ns, outputs[1].end_ns);
  EXPECT_OK(outputs[0].future.Await());
}

}  // namespace
}  // namespace xla::sim
