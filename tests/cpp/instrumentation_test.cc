#include "src/instrumentation.h"

#include "gtest/gtest.h"
#include "xla/pjrt/c/pjrt_c_api_cpu_internal.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"
#include "src/profiler.h"
#include "tsl/platform/status_matchers.h"

namespace xla::sim {
namespace {
TEST(InstrumentationTest, AwaitAndCallbackPreserveErrorOwnership) {
  PJRT_Api api = *pjrt::cpu_plugin::GetCpuPjrtApi();
  AddInstrumentation(api);
  ASSERT_OK_AND_ASSIGN(auto session, StartProfile());
  auto [promise, future] = MakePromise();
  PJRT_Event event{future, {}};
  promise.Set(absl::InternalError("asynchronous test failure"));
  PJRT_Event_Await_Args await_args = {};
  await_args.struct_size = PJRT_Event_Await_Args_STRUCT_SIZE;
  await_args.event = &event;
  PJRT_Error* error = api.PJRT_Event_Await(&await_args);
  ASSERT_NE(error, nullptr);
  EXPECT_EQ(pjrt::PjrtErrorToStatus(error).code(), absl::StatusCode::kInternal);

  bool called = false;
  PJRT_Event_OnReady_Args ready = {};
  ready.struct_size = PJRT_Event_OnReady_Args_STRUCT_SIZE;
  ready.event = &event;
  ready.user_arg = &called;
  ready.callback = [](PJRT_Error* error, void* context) {
    EXPECT_NE(error, nullptr);
    EXPECT_EQ(pjrt::PjrtErrorToStatus(error).code(),
              absl::StatusCode::kInternal);
    *static_cast<bool*>(context) = true;
  };
  EXPECT_EQ(api.PJRT_Event_OnReady(&ready), nullptr);
  EXPECT_TRUE(called);
  StopProfile(session);
}
}  // namespace
}  // namespace xla::sim
