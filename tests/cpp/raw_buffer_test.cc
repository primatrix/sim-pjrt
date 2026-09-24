#include "src/raw_buffer.h"

#include <array>
#include <limits>

#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"
#include "xla/literal_util.h"
#include "xla/pjrt/plugin/xla_cpu/cpu_client_options.h"
#include "xla/pjrt/plugin/xla_cpu/xla_cpu_pjrt_client.h"

namespace xla::sim {
namespace {
TEST(RawBufferTest, ControlWritesAliasStorageAndSurviveBufferDeletion) {
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions()));
  auto literal = LiteralUtil::CreateR1<int32_t>({1, 2, 3, 4});
  ASSERT_OK_AND_ASSIGN(auto buffer,
      client->BufferFromHostLiteral(literal, client->memory_spaces()[0]));
  ASSERT_OK_AND_ASSIGN(auto raw, MakeRawAlias(buffer.get(), 16, false, nullptr, {}));
  ASSERT_OK_AND_ASSIGN(auto slice, raw->Slice(4, 8));
  std::array<int32_t, 2> input{17, 19};
  ASSERT_OK(slice->CopyRawHostToDevice(input.data(), 0, 8).Await());
  ASSERT_OK_AND_ASSIGN(auto observed, buffer->ToLiteral().Await());
  EXPECT_EQ(observed->data<int32_t>()[1], 17);
  EXPECT_EQ(observed->data<int32_t>()[2], 19);
  buffer->Delete();
  buffer.reset();
  std::array<int32_t, 4> output{};
  ASSERT_OK(raw->CopyRawDeviceToHost(output.data(), 0, 16).Await());
  EXPECT_EQ(output, (std::array<int32_t, 4>{1, 17, 19, 4}));
  EXPECT_EQ(raw->GetHostPointer(), nullptr);
  EXPECT_EQ(raw->OpaqueDeviceMemoryDataPointer(), nullptr);
}

TEST(RawBufferTest, PlaceholderUsesLogicalSizeWithoutAllocatingPayload) {
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions()));
  auto literal = LiteralUtil::CreateR0<float>(0);
  ASSERT_OK_AND_ASSIGN(auto buffer,
      client->BufferFromHostLiteral(literal, client->memory_spaces()[0]));
  constexpr int64_t bytes = int64_t{1} << 40;
  ASSERT_OK_AND_ASSIGN(auto raw, MakeRawAlias(buffer.get(), bytes, true, nullptr, {}));
  EXPECT_EQ(raw->GetOnDeviceSizeInBytes(), bytes);
  std::array<unsigned char, 4> output{1, 2, 3, 4};
  ASSERT_OK(raw->CopyRawHostToDevice(output.data(), bytes - 4, 4).Await());
  ASSERT_OK(raw->CopyRawDeviceToHost(output.data(), bytes - 4, 4).Await());
  EXPECT_EQ(output, (std::array<unsigned char, 4>{0, 0, 0, 0}));
  EXPECT_FALSE(raw->CopyRawDeviceToHost(output.data(), -1, 1).Await().ok());
  EXPECT_FALSE(raw->CopyRawDeviceToHost(output.data(), 0, -1).Await().ok());
  EXPECT_FALSE(raw->CopyRawDeviceToHost(output.data(), bytes, 1).Await().ok());
  EXPECT_FALSE(raw->CopyRawDeviceToHost(output.data(), 1,
      std::numeric_limits<int64_t>::max()).Await().ok());
  EXPECT_FALSE(raw->CopyRawHostToDevice(nullptr, 0, 1).Await().ok());
  ASSERT_OK(raw->CopyRawDeviceToHost(nullptr, bytes, 0).Await());
  buffer->Delete();
  EXPECT_FALSE(MakeRawAlias(buffer.get(), bytes, true, nullptr, {}).ok());
}

TEST(RawBufferTest, ProducerErrorPropagatesWithoutWritingDestination) {
  ASSERT_OK_AND_ASSIGN(auto client, GetXlaPjrtCpuClient(CpuClientOptions()));
  auto literal = LiteralUtil::CreateR0<float>(0);
  ASSERT_OK_AND_ASSIGN(auto buffer,
      client->BufferFromHostLiteral(literal, client->memory_spaces()[0]));
  auto [promise, ready] = MakePromise();
  ASSERT_OK_AND_ASSIGN(auto raw,
      MakeRawAlias(buffer.get(), 4096, true, nullptr, Completion{0, ready}));
  int output = 42;
  auto copy = raw->CopyRawDeviceToHost(&output, 0, sizeof(output));
  EXPECT_FALSE(copy.IsReady());
  raw.reset();
  buffer.reset();
  promise.Set(absl::InternalError("producer failed"));
  EXPECT_EQ(copy.Await().code(), absl::StatusCode::kInternal);
  EXPECT_EQ(output, 42);
}
}  // namespace
}  // namespace xla::sim
