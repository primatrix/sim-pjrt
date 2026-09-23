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
// A C API adapter over the CPU functional backend. Ownership and numerical
// control semantics remain upstream; SimRuntime gates public readiness using
// original-HLO work estimates. Optional virtual storage bounds large arrays.
#include <array>
#include <cstdlib>
#include <memory>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/numbers.h"
#include "absl/strings/string_view.h"
#include "mlir/IR/MLIRContext.h"
#include "xla/hlo/builder/xla_computation.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/c/pjrt_c_api_cpu_internal.h"
#include "xla/pjrt/c/pjrt_c_api_helpers.h"
#include "xla/pjrt/c/pjrt_c_api_layouts_extension.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"
#include "xla/pjrt/mlir_to_hlo.h"
#include "xla/pjrt/plugin/xla_cpu/cpu_client_options.h"
#include "xla/pjrt/plugin/xla_cpu/xla_cpu_pjrt_client.h"
#include "xla/pjrt/proto/compile_options.pb.h"
#include "src/hlo_model.h"
#include "src/instrumentation.h"
#include "src/partitioning.h"
#include "src/profiler.h"
#include "src/program_snapshot.h"
#include "src/virtual_storage.h"

namespace xla::sim {
namespace {

const PJRT_Api* Api();

// A synthetic single-host topology, with two chiplets per chip. Coordinates
// have process lifetime because PJRT_NamedValue holds non-owning pointers.
constexpr int kMaxDevices = 256;
const auto kCoordinates = [] {
  std::array<std::array<int64_t, 3>, kMaxDevices> coordinates{};
  for (int i = 0; i < kMaxDevices; ++i) coordinates[i] = {i / 2, 0, 0};
  return coordinates;
}();

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
    coordinates.int64_array_value = kCoordinates[i].data();
    coordinates.value_size = 3;
    auto& attributes = args->client->owned_devices[i].description.attributes;
    attributes.push_back(coordinates);
    for (const absl::string_view name : {"core_on_chip", "slice_index"}) {
      PJRT_NamedValue value = {};
      value.struct_size = PJRT_NamedValue_STRUCT_SIZE;
      value.name = name.data();
      value.name_size = name.size();
      value.type = PJRT_NamedValue_kInt64;
      value.int64_value = name == "core_on_chip" ? i % 2 : 0;
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
  args->device_kind = "TPU7x";
  args->device_kind_size = 5;
  return nullptr;
}

// Cached CPU executables do not contain the original work estimate. Until the
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

absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>> CompileProgram(
    PJRT_Client_Compile_Args* args, ExecutableWork& work,
    std::string& program_json) {
  CompileOptionsProto proto;
  if (!proto.ParseFromArray(args->compile_options,
                            args->compile_options_size)) {
    return absl::InvalidArgumentError("Invalid simulator compile options");
  }
  ABSL_ASSIGN_OR_RETURN(CompileOptions options,
                        CompileOptions::FromProto(proto));
  const auto& build = options.executable_build_options;
  if (build.num_replicas() * build.num_partitions() >
      args->client->client->addressable_device_count()) {
    return absl::InvalidArgumentError(
        "Executable needs more devices than PJRT_SIM_DEVICE_COUNT");
  }
  XlaComputation computation;
  const absl::string_view format(args->program->format,
                                 args->program->format_size);
  if (format == "mlir") {
    mlir::MLIRContext context;
    ABSL_ASSIGN_OR_RETURN(
        auto module,
        ParseMlirModuleString({args->program->code, args->program->code_size},
                              context));
    ABSL_RETURN_IF_ERROR(MlirToXlaComputation(
        *module, computation, options.parameter_is_tupled_arguments,
        /*return_tuple=*/false, &options.executable_build_options));
  } else if (format == "hlo") {
    HloModuleProto module;
    if (!module.ParseFromArray(args->program->code, args->program->code_size)) {
      return absl::InvalidArgumentError("Invalid simulator HLO input");
    }
    computation = XlaComputation(module);
  } else {
    return absl::UnimplementedError("Expected MLIR or HLO program");
  }
  ABSL_ASSIGN_OR_RETURN(HloModuleConfig config,
                        HloModule::CreateModuleConfigFromProto(
                            computation.proto(), build.debug_options()));
  ABSL_ASSIGN_OR_RETURN(
      std::unique_ptr<HloModule> module,
      HloModule::CreateFromProto(computation.proto(), config));
  const int64_t storage_limit = MaxMaterializedBytes(args->client);
  const bool partitioned = storage_limit > 0 && build.num_partitions() > 1;
  if (partitioned) {
    ABSL_RETURN_IF_ERROR(PartitionForVirtualStorage(*module, options));
  }
  auto plan = std::make_shared<ExecutionPlan>(
      BuildExecutionPlan(*module, build.num_partitions(), partitioned));
  if (std::getenv("PJRT_SIM_TRACE") != nullptr) {
    ABSL_ASSIGN_OR_RETURN(
        program_json, CaptureProgramSnapshot(
                          *module, *plan, build.num_partitions(), partitioned));
  }
  ABSL_ASSIGN_OR_RETURN(work.estimate, PrepareForSimulation(*module));
  work.partitioned = partitioned;
  work.num_replicas = build.num_replicas();
  work.plan = std::move(plan);
  work.num_partitions = build.num_partitions();
  if (storage_limit > 0) {
    return CompileVirtual(args->client->client.get(), std::move(module),
                          std::move(options), storage_limit);
  }
  return args->client->client->CompileAndLoad(XlaComputation(module->ToProto()),
                                              std::move(options));
}

PJRT_Error* Compile(PJRT_Client_Compile_Args* args) {
  ProfileCall profile("PJRT Compile");
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_Compile_Args", PJRT_Client_Compile_Args_STRUCT_SIZE,
      args->struct_size));
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Program", PJRT_Program_STRUCT_SIZE, args->program->struct_size));
  ExecutableWork work;
  std::string program_json;
  auto compiled = CompileProgram(args, work, program_json);
  if (!compiled.ok()) {
    profile.activity().Finish(compiled.status());
    return pjrt::StatusToPjRtError(compiled.status());
  }
  args->executable =
      new PJRT_LoadedExecutable(std::move(*compiled), args->client);
  RegisterWork(args->executable, std::move(work), program_json);
  return nullptr;
}

const PJRT_Api* Api() {
  // Expose only extensions implemented by this adapter. In particular, phased
  // compilation must not bypass PrepareForSimulation via the CPU extension.
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
