#include "src/compilation.h"

#include <cstdlib>
#include <string>

#include "absl/status/status.h"
#include "gtest/gtest.h"
#include "src/tpu_compilation.h"
#include "tsl/platform/status_matchers.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "xla/literal.h"
#include "xla/pjrt/plugin/xla_cpu/cpu_client_options.h"
#include "xla/pjrt/plugin/xla_cpu/xla_cpu_pjrt_client.h"

namespace xla::sim {
namespace {

constexpr char kHlo[] = R"(
HloModule matmul
ENTRY main {
  a = f32[2,3] parameter(0)
  b = f32[3,4] parameter(1)
  ROOT dot = f32[2,4] dot(a, b), lhs_contracting_dims={1}, rhs_contracting_dims={0}
}
)";
constexpr char kStableHlo[] = R"(
module @matmul {
  func.func public @main(%a: tensor<2x3xf32>, %b: tensor<3x4xf32>) -> tensor<2x4xf32> {
    %0 = stablehlo.dot %a, %b : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>
    return %0 : tensor<2x4xf32>
  }
}
)";

class CompilationTest : public testing::TestWithParam<bool> {};

TEST_P(CompilationTest, RetainsOriginalInputAndUsesBundles) {
  if (!std::getenv("PJRT_SIM_LIBTPU_PATH")) GTEST_SKIP() << "requires libtpu";
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions{}));
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(kHlo));
  const std::string code =
      GetParam() ? kStableHlo : module->ToProto().SerializeAsString();
  CompilationInput input{GetParam() ? "mlir" : "hlo", code, {}};
  EXPECT_FALSE(input.options.executable_build_options.has_debug_options());
  ASSERT_OK_AND_ASSIGN(auto result,
                       CompileProgram(input, client.get(), true));
  EXPECT_EQ(input.code, code);
  EXPECT_FALSE(input.options.executable_build_options.has_debug_options());
  EXPECT_NE(result.executable, nullptr);
  EXPECT_EQ(result.work.substituted_ops, 1);
  EXPECT_GT(result.work.bundle_timing.bundles, 0);
  EXPECT_GT(result.work.bundle_timing.duration_ns, 0);
  EXPECT_NE(result.program_json.find("libtpu_bundles"), std::string::npos);
  EXPECT_EQ(result.program_json.find("\"plan\""), std::string::npos);
}

INSTANTIATE_TEST_SUITE_P(InputFormats, CompilationTest, testing::Bool());

TEST(CompilationInputTest, RejectsTextDisguisedAsHloProto) {
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions{}));
  CompilationInput input{"hlo", kHlo, {}};
  EXPECT_EQ(CompileProgram(input, client.get(), false).status().code(),
            absl::StatusCode::kInvalidArgument);
}

TEST(CompilationInputTest, RejectsUnsupportedFormat) {
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions{}));
  CompilationInput input{"unknown", "", {}};
  EXPECT_EQ(CompileProgram(input, client.get(), false).status().code(),
            absl::StatusCode::kUnimplemented);
}

TEST(TpuCompilationTest, RequiresLibrary) {
  CompilationInput input{"mlir", kStableHlo, {}};
  auto result = CompileTpuBundles(input, nullptr, "v5e:2x2");
  EXPECT_EQ(result.status().code(), absl::StatusCode::kInvalidArgument);
}

TEST(TpuCompilationTest, RequiresExplicitTopology) {
  CompilationInput input{"mlir", kStableHlo, {}};
  EXPECT_EQ(
      CompileTpuBundles(input, "/missing/libtpu.so", nullptr).status().code(),
      absl::StatusCode::kInvalidArgument);
}

TEST(TpuCompilationTest, ReportsLibraryLoadFailure) {
  CompilationInput input{"mlir", kStableHlo, {}};
  EXPECT_EQ(
      CompileTpuBundles(input, "/missing/libtpu.so", "v5e:2x2").status().code(),
      absl::StatusCode::kUnavailable);
}

TEST(TpuCompilationTest, RealOfflineStableHloCompilation) {
  const char* library = std::getenv("PJRT_SIM_TEST_LIBTPU_PATH");
  if (!library)
    GTEST_SKIP() << "Set PJRT_SIM_TEST_LIBTPU_PATH for real libtpu AOT";
  ASSERT_OK_AND_ASSIGN(auto target, DescribeTpuTopology(library, "v5e:2x2"));
  EXPECT_EQ(target.kind, "TPU v5 lite");
  EXPECT_EQ(target.devices.size(), 4);
  for (const auto& device : target.devices) EXPECT_EQ(device.core_on_chip, 0);
  CompilationInput input{"mlir", kStableHlo, {}};
  ASSERT_OK_AND_ASSIGN(auto timing,
                       CompileTpuBundles(input, library, "v5e:2x2"));
  EXPECT_GT(timing.timing.bundles, 0);
  EXPECT_GT(timing.timing.duration_ns, 0);
  EXPECT_NE(timing.report_json.find("entry_file"), std::string::npos);
  EXPECT_NE(timing.report_json.find("libtpu_bundles"), std::string::npos);
}

TEST(CompilationInputTest, VirtualOutputMaterializesOnlyAtHostRead) {
  if (!std::getenv("PJRT_SIM_LIBTPU_PATH")) GTEST_SKIP() << "requires libtpu";
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions{}));
  ASSERT_OK_AND_ASSIGN(auto module, ParseAndReturnUnverifiedModule(R"(
    HloModule virtual_output
    ENTRY main {
      z = f32[] constant(0)
      ROOT output = f32[1024] broadcast(z), dimensions={}
    }
  )"));
  const std::string code = module->ToProto().SerializeAsString();
  CompilationInput input{"hlo", code, {}};
  ASSERT_OK_AND_ASSIGN(auto result,
                       CompileProgram(input, client.get(), false));
  std::vector<std::vector<PjRtBuffer*>> arguments(1);
  std::optional<std::vector<Future<>>> futures;
  ASSERT_OK_AND_ASSIGN(auto outputs,
                       result.executable->Execute(arguments, {}, futures));
  auto* buffer = outputs[0][0].get();
  EXPECT_FALSE(buffer->IsOnCpu());
  ASSERT_OK_AND_ASSIGN(auto size, buffer->GetOnDeviceSizeInBytes());
  EXPECT_EQ(size, 4096);
  float sample[4] = {1, 2, 3, 4};
  ASSERT_OK(buffer->CopyRawToHost(sample, 4080, sizeof(sample)).Await());
  for (float value : sample) EXPECT_EQ(value, 0);
  EXPECT_EQ(buffer->CopyRawToHost(sample, 4090, sizeof(sample)).Await().code(),
            absl::StatusCode::kInvalidArgument);
  EXPECT_EQ(buffer->CopyRawToHost(sample, -1, 1).Await().code(),
            absl::StatusCode::kInvalidArgument);
  EXPECT_EQ(buffer->AcquireExternalReference().status().code(),
            absl::StatusCode::kFailedPrecondition);
  ASSERT_OK_AND_ASSIGN(auto literal, Literal::Make(buffer->on_device_shape()));
  ASSERT_OK(buffer->ToLiteral(&literal).Await());
  for (float value : literal.data<float>()) EXPECT_EQ(value, 0);
  literal.data<float>()[0] = 17;
  ASSERT_OK(buffer
                ->LazyToLiteral([&literal] {
                  return Future<MutableLiteralBase*>(&literal);
                })
                .Await());
  EXPECT_EQ(literal.data<float>()[0], 0);
}

}  // namespace
}  // namespace xla::sim
