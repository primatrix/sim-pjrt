#include "src/hlo_model.h"

#include "absl/status/status.h"
#include "gtest/gtest.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "src/program_snapshot.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {

TEST(HloModelTest, CountsDotBeforeReplacingIt) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule matmul
    ENTRY main {
      x = bf16[2,3] parameter(0)
      y = bf16[3,4] parameter(1)
      ROOT dot = bf16[2,4] dot(x,y), lhs_contracting_dims={1}, rhs_contracting_dims={0}
    }
  )"));
  ASSERT_OK_AND_ASSIGN(std::string snapshot,
                       CaptureProgramSnapshot(
                           *module, BuildExecutionPlan(*module, 1), 1, false));
  ASSERT_OK_AND_ASSIGN(WorkEstimate work, PrepareForSimulation(*module));
  EXPECT_NE(snapshot.find("\"opcode\":\"dot\""), std::string::npos);
  EXPECT_NE(snapshot.find("\"flops\":48"), std::string::npos);
  EXPECT_EQ(work.dot_flops, 48);
  EXPECT_EQ(work.substituted_ops, 1);
  EXPECT_EQ(module->entry_computation()->root_instruction()->opcode(),
            HloOpcode::kBroadcast);
}

TEST(HloModelTest, PreservesIntegerControlOperations) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule control
    ENTRY main {
      x = s32[4] parameter(0)
      ROOT sum = s32[4] add(x,x)
    }
  )"));
  ASSERT_OK_AND_ASSIGN(WorkEstimate work, PrepareForSimulation(*module));
  EXPECT_EQ(work.substituted_ops, 0);
  EXPECT_EQ(module->entry_computation()->root_instruction()->opcode(),
            HloOpcode::kAdd);
}

TEST(HloModelTest, CountsSharedCalleeOncePerCallWithoutDoubleCountingTraffic) {
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
  ASSERT_OK_AND_ASSIGN(WorkEstimate work, PrepareForSimulation(*module));
  EXPECT_EQ(work.dot_flops, 96);
  EXPECT_EQ(work.logical_bytes, 152);
}

TEST(HloModelTest, RejectsUnknownCustomCall) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule unsupported_call
    ENTRY main {
      x = f32[4] parameter(0)
      ROOT call = f32[4] custom-call(x), custom_call_target="unknown"
    }
  )"));
  EXPECT_EQ(PrepareForSimulation(*module).status().code(),
            absl::StatusCode::kUnimplemented);
}

TEST(HloModelTest, RejectsExternalSideEffects) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule effect
    ENTRY main {
      x = f32[4] parameter(0)
      ROOT call = f32[4] custom-call(x), custom_call_target="tpu_custom_call", custom_call_has_side_effect=true
    }
  )"));
  EXPECT_EQ(PrepareForSimulation(*module).status().code(),
            absl::StatusCode::kUnimplemented);
}

}  // namespace
}  // namespace xla::sim
