#include "src/virtual_storage.h"

#include "absl/status/status.h"
#include "gtest/gtest.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "xla/service/hlo_verifier.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {
TEST(VirtualStorageTest, KeepsLoopControlAndShrinksCarriedTensor) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule loop
    condition {
      p = (s32[], f32[1073741824]) parameter(0)
      i = s32[] get-tuple-element(p), index=0
      end = s32[] constant(3)
      ROOT test = pred[] compare(i, end), direction=LT
    }
    body {
      p = (s32[], f32[1073741824]) parameter(0)
      i = s32[] get-tuple-element(p), index=0
      x = f32[1073741824] get-tuple-element(p), index=1
      one = s32[] constant(1)
      next = s32[] add(i, one)
      y = f32[1073741824] add(x, x)
      ROOT result = (s32[], f32[1073741824]) tuple(next, y)
    }
    ENTRY main {
      x = f32[1073741824] parameter(0)
      i = s32[] constant(0)
      initial = (s32[], f32[1073741824]) tuple(i, x)
      ROOT loop = (s32[], f32[1073741824]) while(initial), condition=condition, body=body
    }
  )"));
  ASSERT_OK(VirtualizeModule(*module, 1024));
  EXPECT_EQ(module->entry_computation()
                ->parameter_instruction(0)
                ->shape()
                .dimensions_size(),
            0);
  EXPECT_EQ(module->entry_computation()
                ->root_instruction()
                ->shape()
                .tuple_shapes(1)
                .dimensions_size(),
            0);
  ASSERT_OK(HloVerifier(false, false).Run(module.get()).status());
}
TEST(VirtualStorageTest, ShrinksSmallOutputWithLargeInput) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule slice
    ENTRY main {
      x = f32[1073741824] parameter(0)
      ROOT slice = f32[4] slice(x), slice={[0:4]}
    }
  )"));
  ASSERT_OK(VirtualizeModule(*module, 1024));
  ASSERT_OK(HloVerifier(false, false).Run(module.get()).status());
  EXPECT_EQ(
      module->entry_computation()->root_instruction()->shape().dimensions(0),
      4);
}
TEST(VirtualStorageTest, AllowsControlFromSmallSimulatedFloats) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule control
    ENTRY main {
      x = f32[1073741824] parameter(0)
      first = f32[1] slice(x), slice={[0:1]}
      ROOT index = s32[1] convert(first)
    }
  )"));
  ASSERT_OK(VirtualizeModule(*module, 1024));
  ASSERT_OK(HloVerifier(false, false).Run(module.get()).status());
}
TEST(VirtualStorageTest, RejectsLargeIntegerAllocation) {
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule integer
    ENTRY main {
      ROOT i = s32[1073741824] iota(), iota_dimension=0
    }
  )"));
  EXPECT_EQ(VirtualizeModule(*module, 1024).code(),
            absl::StatusCode::kResourceExhausted);
}
}  // namespace
}  // namespace xla::sim
