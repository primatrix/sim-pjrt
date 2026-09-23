#include "src/runtime.h"

#include <chrono>
#include <memory>

#include "gtest/gtest.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {

TEST(RuntimeConfigTest, UsesRuntimeSectionWithoutConfusingBundleParameters) {
  ASSERT_OK_AND_ASSIGN(auto config, RuntimeConfig::FromProfile(R"({
    "frequency_hz": 1000000000,
    "runtime": {"launch_ns": 0, "transfer_ns": 100000000,
                "host_bytes_per_second": 1000, "communication_scale": 2}
  })"));
  EXPECT_EQ(config.launch_ns, 0);
  EXPECT_EQ(config.transfer_ns, 100000000);
  EXPECT_EQ(config.host_bytes_per_second, 1000);
  EXPECT_EQ(config.communication_scale, 2);
  EXPECT_EQ(config.link_ns, RuntimeConfig{}.link_ns);
}

TEST(RuntimeConfigTest, RejectsInvalidParametersRatherThanIgnoringThem) {
  for (const char* json :
       {R"({"runtime":[]})", R"({"runtime":{"launch_ns":0.5}})",
        R"({"runtime":{"transfer_ns":-1}})",
        R"({"runtime":{"host_bytes_per_second":0}})",
        R"({"runtime":{"link_ns":"10"}})",
        R"({"runtime":{"communication_scale":true}})",
        R"({"runtime":{"launch_nss":1}})"}) {
    EXPECT_EQ(RuntimeConfig::FromProfile(json).status().code(),
              absl::StatusCode::kInvalidArgument)
        << json;
  }
}

TEST(RuntimeTest, CompletionIsDelayedWithoutProfilingAndDevicesCanOverlap) {
  RuntimeConfig config;
  config.launch_ns = 0;
  SimRuntime runtime(config);
  const auto started = std::chrono::steady_clock::now();
  auto first = runtime.ExecuteTimed(100000000, false, {0}, {}, {}, "first");
  auto other = runtime.ExecuteTimed(100000000, false, {1}, {}, {}, "other");
  auto next = runtime.ExecuteTimed(100000000, false, {0}, {}, {}, "next");
  EXPECT_FALSE(first[0].future.IsReady());
  EXPECT_EQ(next[0].end_ns - first[0].end_ns, 100000000);
  EXPECT_LT(other[0].end_ns, next[0].end_ns);
  EXPECT_OK(next[0].future.Await());
  EXPECT_GE(std::chrono::steady_clock::now() - started,
            std::chrono::milliseconds(200));
}

TEST(RuntimeTest, CpuReadinessAndErrorsAreNotHiddenByModeledCompletion) {
  SimRuntime runtime(RuntimeConfig{});
  auto [promise, cpu] = MakePromise();
  Completion completed = runtime.Transfer(-1, 0, 0, {}, {});
  Future<> ready = JoinFutures({completed.future, cpu});
  ASSERT_OK(completed.future.Await());
  EXPECT_FALSE(ready.IsReady());
  promise.Set(absl::InternalError("functional backend failure"));
  EXPECT_EQ(ready.Await().code(), absl::StatusCode::kInternal);
}

TEST(RuntimeTest, BundleTimingUsesProgramDurationAndWaitsForInputsAndCpu) {
  RuntimeConfig config;
  config.launch_ns = 0;
  config.transfer_ns = 20000000;
  SimRuntime runtime(config);
  auto input = runtime.Transfer(-1, 0, 0, {}, {});
  auto first =
      runtime.ExecuteTimed(30000000, true, {0, 1}, {input}, {}, "bundles");
  EXPECT_EQ(first[0].end_ns, input.end_ns + 30000000);
  EXPECT_EQ(first[0].end_ns, first[1].end_ns);
  auto next = runtime.ExecuteTimed(10000000, false, {0, 1}, {}, {}, "next");
  EXPECT_EQ(next[0].end_ns, first[0].end_ns + 10000000);
  auto [promise, cpu] = MakePromise();
  auto ready = JoinFutures({next[0].future, cpu});
  ASSERT_OK(next[0].future.Await());
  EXPECT_FALSE(ready.IsReady());
  promise.Set(absl::InternalError("CPU output failed"));
  EXPECT_EQ(ready.Await().code(), absl::StatusCode::kInternal);
}

TEST(RuntimeTest, DumpOnlySkipsDelaysButPreservesDependencyErrors) {
  RuntimeConfig config;
  config.simulate_timing = false;
  SimRuntime runtime(config);
  auto [promise, future] = MakePromise();
  Completion input{0, future};
  auto transfer = runtime.Transfer(-1, 0, 1000000000000, input, {});
  auto executions = runtime.ExecuteTimed(1000000000000, false, {0, 1},
                                         {transfer}, {}, "dump");
  EXPECT_FALSE(executions[0].future.IsReady());
  promise.Set(absl::InternalError("dependency failed"));
  for (const auto& execution : executions) {
    EXPECT_TRUE(execution.future.IsReady());
    EXPECT_EQ(execution.future.Await().code(), absl::StatusCode::kInternal);
  }
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

}  // namespace
}  // namespace xla::sim
