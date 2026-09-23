// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "src/execution_plan.h"

#include <algorithm>

#include "gtest/gtest.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {

TEST(ExecutionPlanTest, PallasDeclaredCostsSurviveTupleOutputsAndManualScope) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  q = bf16[1,2,128,128] parameter(0)
  ROOT attention = (bf16[1,2,128,128]) custom-call(q), custom_call_target="tpu_custom_call", sharding={{manual}}, backend_config={"custom_call_config":{"cost_estimate":{"flops":16842752,"transcendentals":"32768","bytes_accessed":262144}}}
})"));
  // These are the costs emitted by JAX 0.11.1 FlashAttention for this shape.
  ExecutionPlan plan = BuildExecutionPlan(*module, 1);
  ASSERT_EQ(plan.cost_gaps, 0);
  const auto found = std::find_if(
      plan.nodes.begin(), plan.nodes.end(),
      [](const PlanNode& node) { return node.name == "attention"; });
  ASSERT_NE(found, plan.nodes.end());
  const PlanNode& node = *found;
  EXPECT_EQ(node.flops, 16842752);
  EXPECT_EQ(node.transcendentals, 32768);
  EXPECT_EQ(node.bytes, 262144);
  EXPECT_EQ(node.cost_source, "pallas_cost_estimate");
  EXPECT_EQ(plan.kernel_flops, node.flops);
  EXPECT_EQ(plan.kernel_transcendentals, node.transcendentals);
  EXPECT_EQ(plan.kernel_bytes, node.bytes);
}

TEST(ExecutionPlanTest, PallasReplicatedCostsAreNotDividedByDeviceCount) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  q = bf16[4] parameter(0), sharding={replicated}
  ROOT attention = bf16[4] custom-call(q), custom_call_target="tpu_custom_call", sharding={replicated}, backend_config={"custom_call_config":{"cost_estimate":{"flops":800,"transcendentals":40,"bytes_accessed":16}}}
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 8);
  ASSERT_EQ(plan.cost_gaps, 0);
  double flops = 0;
  for (const PlanNode& node : plan.nodes) flops += node.flops;
  EXPECT_EQ(flops, 800);
}

TEST(ExecutionPlanTest, PallasWithoutKnownScopeStaysUnknown) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  q = bf16[4] parameter(0)
  ROOT attention = bf16[4] custom-call(q), custom_call_target="tpu_custom_call", backend_config={"custom_call_config":{"cost_estimate":{"flops":800,"transcendentals":40,"bytes_accessed":16}}}
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 8);
  EXPECT_EQ(plan.cost_gaps, 1);
  for (const PlanNode& node : plan.nodes)
    EXPECT_EQ(node.kind, PlanNode::Kind::kBarrier);
}

TEST(ExecutionPlanTest, PallasInManualCalleeIsCountedAtEveryCallSite) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
local {
  q = bf16[4] parameter(0)
  ROOT attention = bf16[4] custom-call(q), custom_call_target="tpu_custom_call", backend_config={"custom_call_config":{"cost_estimate":{"flops":800,"transcendentals":40,"bytes_accessed":16}}}
}
ENTRY main {
  q = bf16[4] parameter(0), sharding={manual}
  a = bf16[4] call(q), to_apply=local
  b = bf16[4] call(q), to_apply=local
  ROOT result = (bf16[4],bf16[4]) tuple(a,b)
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 8);
  ASSERT_EQ(plan.cost_gaps, 0);
  double flops = 0;
  for (const PlanNode& node : plan.nodes) flops += node.flops;
  EXPECT_EQ(flops, 1600);
  EXPECT_EQ(plan.kernel_flops, 1600);
  EXPECT_EQ(plan.kernel_bytes, 32);
}

TEST(ExecutionPlanTest, MalformedOrCommunicatingPallasStaysUnknown) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  ROOT attention = bf16[4] custom-call(), custom_call_target="tpu_custom_call"
})"));
  for (
      const char* config :
      {"not JSON", "{}",
       R"({"custom_call_config":{"cost_estimate":{"flops":1,"transcendentals":0,"bytes_accessed":-1}}})",
       R"({"custom_call_config":{"cost_estimate":{"flops":1,"transcendentals":0,"bytes_accessed":"NaN"}}})",
       R"({"custom_call_config":{"cost_estimate":{"flops":true,"transcendentals":0,"bytes_accessed":16}}})",
       R"({"custom_call_config":{"cost_estimate":{"flops":1,"transcendentals":0,"bytes_accessed":1.5}}})",
       R"({"custom_call_config":{"cost_estimate":{"flops":1,"transcendentals":0,"bytes_accessed":16,"remote_bytes_transferred":1}}})",
       R"({"custom_call_config":{"has_communication":true,"cost_estimate":{"flops":1,"transcendentals":0,"bytes_accessed":16}}})"}) {
    module->entry_computation()
        ->root_instruction()
        ->set_raw_backend_config_string(config);
    ExecutionPlan plan = BuildExecutionPlan(*module, 1);
    EXPECT_EQ(plan.cost_gaps, 1) << config;
    for (const PlanNode& node : plan.nodes) {
      EXPECT_EQ(node.flops, 0);
      EXPECT_EQ(node.transcendentals, 0);
      EXPECT_EQ(node.bytes, 0);
      EXPECT_TRUE(node.cost_source.empty());
    }
  }
}

TEST(ExecutionPlanTest, ContractingShardingCreatesLocalWorkAndAllReduce) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  x = bf16[8,16] parameter(0), sharding={devices=[1,2]0,1}
  w = bf16[16,4] parameter(1), sharding={devices=[2,1]0,1}
  ROOT y = bf16[8,4] dot(x,w), lhs_contracting_dims={1}, rhs_contracting_dims={0}, sharding={replicated}
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 2);
  double flops = 0;
  int collectives = 0;
  for (const PlanNode& node : plan.nodes) {
    flops += node.flops;
    collectives += node.kind == PlanNode::Kind::kAllReduce;
  }
  EXPECT_EQ(flops, 2 * 8 * 8 * 4);
  EXPECT_EQ(collectives, 1);
  EXPECT_EQ(plan.cost_gaps, 0);
}

TEST(ExecutionPlanTest, UnknownShardingIsNotDividedByDeviceCount) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
ENTRY main {
  x = bf16[8,16] parameter(0)
  w = bf16[16,4] parameter(1)
  ROOT y = bf16[8,4] dot(x,w), lhs_contracting_dims={1}, rhs_contracting_dims={0}
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 2);
  EXPECT_EQ(plan.cost_gaps, 1);
  for (const PlanNode& node : plan.nodes) EXPECT_EQ(node.flops, 0);
}

TEST(ExecutionPlanTest, StaticCalleeWorkOccursAtEachCallSite) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule test
callee {
  x = f32[4] parameter(0)
  ROOT y = f32[4] add(x,x)
}
ENTRY main {
  x = f32[4] parameter(0)
  a = f32[4] call(x), to_apply=callee
  ROOT b = f32[4] call(a), to_apply=callee
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 1);
  double bytes = 0;
  for (const PlanNode& node : plan.nodes) bytes += node.bytes;
  EXPECT_EQ(bytes, 2 * 3 * 4 * sizeof(float));
  EXPECT_EQ(plan.cost_gaps, 0);
}

TEST(ExecutionPlanTest, PartitionedDotUsesLocalShapesAndExplicitCommunication) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule local
sum {
  x = bf16[] parameter(0)
  y = bf16[] parameter(1)
  ROOT z = bf16[] add(x,y)
}
ENTRY main {
  x = bf16[8,8] parameter(0)
  w = bf16[8,4] parameter(1)
  dot = bf16[8,4] dot(x,w), lhs_contracting_dims={1}, rhs_contracting_dims={0}
  ROOT reduced = bf16[8,4] all-reduce(dot), replica_groups={{0,1}}, channel_id=1, use_global_device_ids=true, to_apply=sum
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 2, true);
  EXPECT_EQ(plan.cost_gaps, 0);
  double flops = 0, bytes = 0;
  int collectives = 0;
  for (const PlanNode& node : plan.nodes) {
    flops += node.flops;
    if (node.kind == PlanNode::Kind::kAllReduce) {
      ++collectives;
      bytes += node.bytes;
    }
  }
  EXPECT_EQ(flops, 512);
  EXPECT_EQ(collectives, 1);
  EXPECT_EQ(bytes, 64);
}

TEST(ExecutionPlanTest, ReshardTransfersUseLocalPayloads) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
HloModule transfers
ENTRY main {
  x = f32[8,8] parameter(0)
  exchange = f32[8,8] all-to-all(x), dimensions={0}, replica_groups={{0,1}}, channel_id=1
  ROOT rotate = f32[8,8] collective-permute(exchange), source_target_pairs={{0,1},{1,0}}, channel_id=2
})"));
  ExecutionPlan plan = BuildExecutionPlan(*module, 2, true);
  EXPECT_EQ(plan.cost_gaps, 0);
  int count = 0;
  for (const PlanNode& node : plan.nodes) {
    if (node.kind != PlanNode::Kind::kTransfers) continue;
    EXPECT_EQ(node.transfers.size(), 2);
    EXPECT_EQ(node.bytes, count++ == 0 ? 128 : 256);
  }
  EXPECT_EQ(count, 2);
}

}  // namespace
}  // namespace xla::sim
