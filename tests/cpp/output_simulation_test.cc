
#include "src/output_simulation.h"

#include "absl/status/status.h"
#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/hlo/parser/hlo_parser.h"

namespace xla::sim {
namespace {

TEST(OutputSimulationTest, ReplacesFloatingDot) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule matmul
    ENTRY main {
      x = bf16[2,3] parameter(0)
      y = bf16[3,4] parameter(1)
      ROOT dot = bf16[2,4] dot(x,y), lhs_contracting_dims={1}, rhs_contracting_dims={0}
    }
  )"));
  ASSERT_OK_AND_ASSIGN(auto substituted_ops,
                       SubstituteSimulationOutputs(*module));
  EXPECT_EQ(substituted_ops, 1);
  EXPECT_EQ(module->entry_computation()->root_instruction()->opcode(),
            HloOpcode::kBroadcast);
}

TEST(OutputSimulationTest, PreservesIntegerControlOperations) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule control
    ENTRY main {
      x = s32[4] parameter(0)
      ROOT sum = s32[4] add(x,x)
    }
  )"));
  ASSERT_OK_AND_ASSIGN(auto substituted_ops,
                       SubstituteSimulationOutputs(*module));
  EXPECT_EQ(substituted_ops, 0);
  EXPECT_EQ(module->entry_computation()->root_instruction()->opcode(),
            HloOpcode::kAdd);
}

TEST(OutputSimulationTest, ReplacesSharedCallee) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule shared_callee
    multiply {
      x = bf16[2,3] parameter(0)
      y = bf16[3,4] parameter(1)
      ROOT dot = bf16[2,4] dot(x,y), lhs_contracting_dims={1}, rhs_contracting_dims={0}
    }
    ENTRY main {
      x = bf16[2,3] parameter(0)
      y = bf16[3,4] parameter(1)
      a = bf16[2,4] call(x,y), to_apply=multiply
      b = bf16[2,4] call(x,y), to_apply=multiply
      ROOT sum = bf16[2,4] add(a,b)
    }
  )"));
  ASSERT_OK_AND_ASSIGN(auto substituted_ops,
                       SubstituteSimulationOutputs(*module));
  EXPECT_EQ(substituted_ops, 1);
}

TEST(OutputSimulationTest, RejectsUnknownCustomCall) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule unsupported_call
    ENTRY main {
      x = f32[4] parameter(0)
      ROOT call = f32[4] custom-call(x), custom_call_target="unknown"
    }
  )"));
  EXPECT_EQ(SubstituteSimulationOutputs(*module).status().code(),
            absl::StatusCode::kUnimplemented);
}

TEST(OutputSimulationTest, SupportsUninitializedScratchAllocation) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule scratch
    ENTRY main {
      scratch = s32[4] custom-call(), custom_call_target="AllocateBuffer"
      input = s32[4] parameter(0)
      ROOT sum = s32[4] add(input, scratch)
    }
  )"));
  ASSERT_OK_AND_ASSIGN(auto substituted_ops,
                       SubstituteSimulationOutputs(*module));
  EXPECT_EQ(substituted_ops, 1);
  auto* root = module->entry_computation()->root_instruction();
  EXPECT_EQ(root->opcode(), HloOpcode::kAdd);
  EXPECT_EQ(root->operand(0)->opcode(), HloOpcode::kParameter);
  EXPECT_EQ(root->operand(1)->opcode(), HloOpcode::kBroadcast);
  EXPECT_EQ(root->operand(1)->operand(0)->literal().GetFirstElement<int32_t>(),
            0);
}

TEST(OutputSimulationTest, RejectsAllocationWithOperands) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule invalid_allocation
    ENTRY main {
      input = s32[4] parameter(0)
      ROOT scratch = s32[4] custom-call(input), custom_call_target="AllocateBuffer"
    }
  )"));
  EXPECT_EQ(SubstituteSimulationOutputs(*module).status().code(),
            absl::StatusCode::kUnimplemented);
}

TEST(OutputSimulationTest, SupportsFusedMoeInternalCollectiveEffects) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule fused_moe
    ENTRY main {
      tokens = bf16[16,2,128] parameter(0)
      weight = bf16[4,256,128] parameter(1)
      scores = f32[16,128] parameter(2)
      ids = s32[16,128] parameter(3)
      scratch = bf16[4,16,2,128] parameter(4)
      ROOT call = bf16[16,256] custom-call(tokens, weight, weight, weight,
          scores, ids, scratch, scratch, scratch),
          custom_call_target="tpu_custom_call", custom_call_has_side_effect=true,
          metadata={op_name="jit(model)/fused-moe-k_8-renorm_k/pallas_call"}
    }
  )"));
  // Similar shapes alone must never admit an arbitrary effectful kernel.
  auto* call = module->entry_computation()->root_instruction();
  auto metadata = call->metadata();
  metadata.set_op_name("jit(model)/external_callback");
  call->set_metadata(metadata);
  EXPECT_EQ(SubstituteSimulationOutputs(*module).status().code(),
            absl::StatusCode::kUnimplemented);
  metadata.set_op_name("jit(model)/fused-moe-k_8-renorm_k/pallas_call");
  call->set_metadata(metadata);
  ASSERT_OK_AND_ASSIGN(auto substituted_ops, SubstituteSimulationOutputs(*module));
  EXPECT_EQ(substituted_ops, 1);
  EXPECT_EQ(module->entry_computation()->root_instruction()->opcode(),
            HloOpcode::kBroadcast);
}

TEST(OutputSimulationTest, RejectsExternalSideEffects) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule effect
    ENTRY main {
      x = f32[4] parameter(0)
      ROOT call = f32[4] custom-call(x), custom_call_target="tpu_custom_call", custom_call_has_side_effect=true
    }
  )"));
  EXPECT_EQ(SubstituteSimulationOutputs(*module).status().code(),
            absl::StatusCode::kUnimplemented);
}

}  // namespace
}  // namespace xla::sim
