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
#include "xla/pjrt/sim/hlo_model.h"

#include "absl/status/status.h"
#include "gtest/gtest.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "xla/pjrt/sim/program_snapshot.h"
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
