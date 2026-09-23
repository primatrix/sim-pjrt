// A C API adapter over the CPU functional backend. Ownership and numerical
// control semantics remain upstream; SimRuntime gates public readiness using
// libtpu bundle durations. Virtual storage bounds large arrays by default.
#include <cstdlib>
#include <memory>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/numbers.h"
#include "absl/strings/string_view.h"
#include "src/compilation.h"
#include "src/instrumentation.h"
#include "src/profiler.h"
#include "src/tpu_compilation.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/c/pjrt_c_api_cpu_internal.h"
#include "xla/pjrt/c/pjrt_c_api_helpers.h"
#include "xla/pjrt/c/pjrt_c_api_layouts_extension.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"
#include "xla/pjrt/plugin/xla_cpu/cpu_client_options.h"
#include "xla/pjrt/plugin/xla_cpu/xla_cpu_pjrt_client.h"
#include "xla/pjrt/proto/compile_options.pb.h"

namespace xla::sim {
namespace {

const PJRT_Api* Api();

const absl::StatusOr<TpuTopology>& TargetTopology() {
  static const auto target = []() -> absl::StatusOr<TpuTopology> {
    const char* library = std::getenv("PJRT_SIM_LIBTPU_PATH");
    return DescribeTpuTopology(library, std::getenv("PJRT_SIM_TPU_TOPOLOGY"));
  }();
  return target;
}

constexpr int kMaxDevices = 256;

PJRT_Error* Create(PJRT_Client_Create_Args* args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_Create_Args", PJRT_Client_Create_Args_STRUCT_SIZE,
      args->struct_size));
  CpuClientOptions options;
  PJRT_ASSIGN_OR_RETURN(RuntimeConfig runtime_config,
                        RuntimeConfig::FromEnvironment());
  int device_count = 1;
  if (const char* value = std::getenv("PJRT_SIM_DEVICE_COUNT")) {
    if (!absl::SimpleAtoi(value, &device_count) || device_count < 1 ||
        device_count > kMaxDevices || (device_count > 1 && device_count % 2)) {
      return pjrt::StatusToPjRtError(absl::InvalidArgumentError(
          "PJRT_SIM_DEVICE_COUNT must be 1 or an even number from 2 to 256"));
    }
  }
  options.cpu_device_count = device_count;
  options.asynchronous = true;
  const auto& target = TargetTopology();
  PJRT_RETURN_IF_ERROR(target.status());
  if (device_count > target->devices.size())
    return pjrt::StatusToPjRtError(absl::InvalidArgumentError(
        "PJRT_SIM_DEVICE_COUNT exceeds the libtpu topology device count"));
  if (args->num_options != 0) {
    return pjrt::StatusToPjRtError(
        absl::InvalidArgumentError("Simulator does not accept client options"));
  }
  PJRT_ASSIGN_OR_RETURN(std::unique_ptr<PjRtClient> client,
                        GetXlaPjrtCpuClient(options));
  args->client = pjrt::CreateWrapperClient(Api(), std::move(client));
  RegisterRuntime(args->client, runtime_config);
  // JAX mesh construction needs unique (coords, core_on_chip) pairs.
  for (int i = 0; i < device_count; ++i) {
    PJRT_NamedValue coordinates = {};
    coordinates.struct_size = PJRT_NamedValue_STRUCT_SIZE;
    coordinates.name = "coords";
    coordinates.name_size = 6;
    coordinates.type = PJRT_NamedValue_kInt64List;
    coordinates.int64_array_value = target->devices[i].coords.data();
    coordinates.value_size = 3;
    auto& attributes = args->client->owned_devices[i].description.attributes;
    attributes.push_back(coordinates);
    for (const absl::string_view name : {"core_on_chip", "slice_index"}) {
      PJRT_NamedValue value = {};
      value.struct_size = PJRT_NamedValue_STRUCT_SIZE;
      value.name = name.data();
      value.name_size = name.size();
      value.type = PJRT_NamedValue_kInt64;
      value.int64_value =
          name == "core_on_chip" ? target->devices[i].core_on_chip : 0;
      value.value_size = 1;
      attributes.push_back(value);
    }
  }
  return nullptr;
}

PJRT_Error* PlatformName(PJRT_Client_PlatformName_Args* args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_PlatformName_Args",
      PJRT_Client_PlatformName_Args_STRUCT_SIZE, args->struct_size));
  args->platform_name = "tpu";
  args->platform_name_size = 3;
  return nullptr;
}

PJRT_Error* DeviceKind(PJRT_DeviceDescription_Kind_Args* args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_DeviceDescription_Kind_Args",
      PJRT_DeviceDescription_Kind_Args_STRUCT_SIZE, args->struct_size));
  const auto& target = TargetTopology();
  PJRT_RETURN_IF_ERROR(target.status());
  args->device_kind = target->kind.data();
  args->device_kind_size = target->kind.size();
  return nullptr;
}

// Cached CPU executables do not contain the bundle timing metadata. Until the
// simulator has its own serialization format, always compile through this API.
PJRT_Error* Deserialize(PJRT_Executable_DeserializeAndLoad_Args*) {
  return pjrt::StatusToPjRtError(absl::UnimplementedError(
      "Simulator executable deserialization is not supported"));
}

PJRT_Error* Serialize(PJRT_Executable_Serialize_Args*) {
  return pjrt::StatusToPjRtError(absl::UnimplementedError(
      "Simulator executable serialization is not supported"));
}

PJRT_Error* Load(PJRT_Client_Load_Args*) {
  return pjrt::StatusToPjRtError(absl::UnimplementedError(
      "Simulator executables must be created by Compile"));
}

PJRT_Error* Compile(PJRT_Client_Compile_Args* args) {
  ProfileCall profile("PJRT Compile");
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_Compile_Args", PJRT_Client_Compile_Args_STRUCT_SIZE,
      args->struct_size));
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Program", PJRT_Program_STRUCT_SIZE, args->program->struct_size));
  CompileOptionsProto proto;
  if (!proto.ParseFromArray(args->compile_options,
                            args->compile_options_size)) {
    const auto status =
        absl::InvalidArgumentError("Invalid simulator compile options");
    profile.activity().Finish(status);
    return pjrt::StatusToPjRtError(status);
  }
  auto options = CompileOptions::FromProto(proto);
  if (!options.ok()) {
    profile.activity().Finish(options.status());
    return pjrt::StatusToPjRtError(options.status());
  }
  CompilationInput input{{args->program->format, args->program->format_size},
                         {args->program->code, args->program->code_size},
                         std::move(*options)};
  auto compiled = CompileProgram(input, args->client->client.get(),
                                 std::getenv("PJRT_SIM_TRACE") != nullptr);
  if (!compiled.ok()) {
    profile.activity().Finish(compiled.status());
    return pjrt::StatusToPjRtError(compiled.status());
  }
  args->executable =
      new PJRT_LoadedExecutable(std::move(compiled->executable), args->client);
  RegisterWork(args->executable, std::move(compiled->work),
               compiled->program_json);
  return nullptr;
}

const PJRT_Api* Api() {
  // Expose only extensions implemented by this adapter. In particular, phased
  // compilation must not bypass CompileProgram via the CPU extension.
  static PJRT_Layouts_Extension layouts =
      pjrt::CreateLayoutsExtension(&ProfilerExtension()->base);
  static const PJRT_Api api = [] {
    PJRT_Api result = *pjrt::cpu_plugin::GetCpuPjrtApi();
    result.extension_start = &layouts.base;
    result.PJRT_Client_Create = Create;
    result.PJRT_Client_PlatformName = PlatformName;
    result.PJRT_DeviceDescription_Kind = DeviceKind;
    // Static simulator attributes live on DeviceDescription. Let JAX use that
    // interface instead of the CPU runtime's dynamic device attributes.
    result.PJRT_Device_GetAttributes = nullptr;
    result.PJRT_Client_Compile = Compile;
    result.PJRT_Client_Load = Load;
    result.PJRT_Executable_Serialize = Serialize;
    result.PJRT_Executable_DeserializeAndLoad = Deserialize;
    AddInstrumentation(result);
    return result;
  }();
  return &api;
}

}  // namespace
}  // namespace xla::sim

extern "C" __attribute__((visibility("default"))) const PJRT_Api* GetPjrtApi() {
  return xla::sim::Api();
}
