#include "src/tpu_compilation.h"

#include <dlfcn.h>

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <map>
#include <mutex>
#include <set>
#include <string>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/proto/compile_options.pb.h"

namespace xla::sim {
namespace {
absl::Status Consume(const PJRT_Api* api, PJRT_Error* error) {
  if (!error) return absl::OkStatus();
  absl::Status status = pjrt::PjrtErrorToStatus(error, api);
  PJRT_Error_Destroy_Args args{};
  args.struct_size = PJRT_Error_Destroy_Args_STRUCT_SIZE;
  args.error = error;
  api->PJRT_Error_Destroy(&args);
  return status;
}

absl::StatusOr<const PJRT_Api*> Load(const char* path, const char* topology) {
  if (!path || !*path)
    return absl::InvalidArgumentError("A libtpu library path is required");
  if (!topology || !*topology)
    return absl::InvalidArgumentError(
        "PJRT_SIM_TPU_TOPOLOGY is required for libtpu AOT compilation");
  static std::mutex mutex;
  // Plugin code and its background threads must remain loaded for process life.
  static auto* apis = new std::map<std::string, const PJRT_Api*>;
  std::lock_guard<std::mutex> lock(mutex);
  if (auto it = apis->find(path); it != apis->end()) return it->second;
  ABSL_ASSIGN_OR_RETURN(auto dump_dir, BundleDumpDirectory());
  const char* previous = std::getenv("LIBTPU_INIT_ARGS");
  const std::string flags = absl::StrCat(
      previous ? previous : "", " --xla_jf_dump_to=", dump_dir,
      " --xla_jf_dump_llo_text=true --xla_jf_dump_hlo_text=true",
      " --xla_jf_debug_level=2 --xla_jf_dump_use_subdirectories=false",
      " --xla_jf_dump_llo_pass_label_regex=^(final_bundles|deduplication-map)"
      "$");
  if (setenv("LIBTPU_INIT_ARGS", flags.c_str(), 1))
    return absl::UnavailableError("Cannot configure libtpu bundle dumps");
  void* library = dlopen(path, RTLD_NOW | RTLD_LOCAL);
  if (!library)
    return absl::UnavailableError(absl::StrCat("libtpu: ", dlerror()));
  auto get_api =
      reinterpret_cast<const PJRT_Api* (*)()>(dlsym(library, "GetPjrtApi"));
  if (!get_api) {
    dlclose(library);
    return absl::InvalidArgumentError("libtpu does not export GetPjrtApi");
  }
  const PJRT_Api* api = get_api();
  if (!api || api->struct_size < PJRT_STRUCT_SIZE(PJRT_Api, PJRT_Compile) ||
      api->pjrt_api_version.major_version != PJRT_API_MAJOR ||
      !api->PJRT_Plugin_Initialize || !api->PJRT_Compile ||
      !api->PJRT_TopologyDescription_Create ||
      !api->PJRT_TopologyDescription_Destroy ||
      !api->PJRT_TopologyDescription_GetDeviceDescriptions ||
      !api->PJRT_DeviceDescription_Kind || !api->PJRT_DeviceDescription_Id ||
      !api->PJRT_DeviceDescription_Attributes ||
      !api->PJRT_Executable_Destroy) {
    return absl::UnimplementedError("libtpu lacks compatible PJRT AOT APIs");
  }
  PJRT_Plugin_Initialize_Args init{};
  init.struct_size = PJRT_Plugin_Initialize_Args_STRUCT_SIZE;
  ABSL_RETURN_IF_ERROR(Consume(api, api->PJRT_Plugin_Initialize(&init)));
  (*apis)[path] = api;
  return api;
}

struct Artifacts {
  const PJRT_Api* api;
  PJRT_TopologyDescription* topology = nullptr;
  PJRT_Executable* executable = nullptr;
  ~Artifacts() {
    if (executable) {
      PJRT_Executable_Destroy_Args args{};
      args.struct_size = PJRT_Executable_Destroy_Args_STRUCT_SIZE;
      args.executable = executable;
      (void)Consume(api, api->PJRT_Executable_Destroy(&args));
    }
    if (topology) {
      PJRT_TopologyDescription_Destroy_Args args{};
      args.struct_size = PJRT_TopologyDescription_Destroy_Args_STRUCT_SIZE;
      args.topology = topology;
      (void)Consume(api, api->PJRT_TopologyDescription_Destroy(&args));
    }
  }
};

absl::Status CreateTopology(Artifacts& artifacts, const char* topology) {
  PJRT_TopologyDescription_Create_Args create{};
  create.struct_size = PJRT_TopologyDescription_Create_Args_STRUCT_SIZE;
  create.topology_name = topology;
  create.topology_name_size = std::char_traits<char>::length(topology);
  ABSL_RETURN_IF_ERROR(Consume(
      artifacts.api, artifacts.api->PJRT_TopologyDescription_Create(&create)));
  artifacts.topology = create.topology;
  return absl::OkStatus();
}
}  // namespace

absl::StatusOr<TpuTopology> DescribeTpuTopology(const char* library,
                                                const char* topology) {
  ABSL_ASSIGN_OR_RETURN(const PJRT_Api* api, Load(library, topology));
  Artifacts artifacts{api};
  ABSL_RETURN_IF_ERROR(CreateTopology(artifacts, topology));
  PJRT_TopologyDescription_GetDeviceDescriptions_Args devices{};
  devices.struct_size =
      PJRT_TopologyDescription_GetDeviceDescriptions_Args_STRUCT_SIZE;
  devices.topology = artifacts.topology;
  ABSL_RETURN_IF_ERROR(Consume(
      api, api->PJRT_TopologyDescription_GetDeviceDescriptions(&devices)));
  if (!devices.num_descriptions)
    return absl::InvalidArgumentError("libtpu topology has no devices");
  PJRT_DeviceDescription_Kind_Args kind{};
  kind.struct_size = PJRT_DeviceDescription_Kind_Args_STRUCT_SIZE;
  kind.device_description = devices.descriptions[0];
  ABSL_RETURN_IF_ERROR(Consume(api, api->PJRT_DeviceDescription_Kind(&kind)));
  TpuTopology result{std::string(kind.device_kind, kind.device_kind_size), {}};
  for (size_t i = 0; i < devices.num_descriptions; ++i) {
    PJRT_DeviceDescription_Id_Args id{};
    id.struct_size = PJRT_DeviceDescription_Id_Args_STRUCT_SIZE;
    id.device_description = devices.descriptions[i];
    ABSL_RETURN_IF_ERROR(Consume(api, api->PJRT_DeviceDescription_Id(&id)));
    PJRT_DeviceDescription_Attributes_Args attrs{};
    attrs.struct_size = PJRT_DeviceDescription_Attributes_Args_STRUCT_SIZE;
    attrs.device_description = devices.descriptions[i];
    ABSL_RETURN_IF_ERROR(
        Consume(api, api->PJRT_DeviceDescription_Attributes(&attrs)));
    TpuDeviceDescription device{id.id};
    bool has_coords = false;
    for (size_t a = 0; a < attrs.num_attributes; ++a) {
      const auto& attr = attrs.attributes[a];
      const absl::string_view name(attr.name, attr.name_size);
      if (name == "coords" && attr.type == PJRT_NamedValue_kInt64List &&
          attr.value_size == 3) {
        std::copy_n(attr.int64_array_value, 3, device.coords.begin());
        has_coords = true;
      } else if (name == "core_on_chip" &&
                 attr.type == PJRT_NamedValue_kInt64) {
        device.core_on_chip = attr.int64_value;
      }
    }
    if (!has_coords)
      return absl::UnimplementedError(
          "libtpu topology has no device coordinates");
    result.devices.push_back(device);
  }
  std::sort(result.devices.begin(), result.devices.end(),
            [](const auto& a, const auto& b) { return a.id < b.id; });
  return result;
}

absl::StatusOr<BundleCompilation> CompileTpuBundles(
    const CompilationInput& input, const char* library, const char* topology) {
  ABSL_ASSIGN_OR_RETURN(const PJRT_Api* api, Load(library, topology));
  const char* profile = std::getenv("PJRT_SIM_BUNDLE_PROFILE");
  if (!profile || !*profile)
    return absl::InvalidArgumentError(
        "libtpu bundle timing requires PJRT_SIM_BUNDLE_PROFILE");
  Artifacts artifacts{api};
  ABSL_RETURN_IF_ERROR(CreateTopology(artifacts, topology));

  // Dump flags are process-global. Serialize collection with compilation so
  // an artifact cannot be attributed to another executable in this plugin.
  static std::mutex compilation_mutex;
  std::lock_guard<std::mutex> lock(compilation_mutex);
  ABSL_ASSIGN_OR_RETURN(auto dump_dir, BundleDumpDirectory());
  auto final_bundles = [&]() -> absl::StatusOr<std::set<std::string>> {
    std::set<std::string> paths;
    std::error_code error;
    std::filesystem::directory_iterator it(dump_dir, error), end;
    for (; !error && it != end; it.increment(error)) {
      const std::string name = it->path().filename().string();
      if ((name.size() >= 18 &&
           name.compare(name.size() - 18, 18, "-final_bundles.txt") == 0) ||
          (name.size() >= 22 &&
           name.compare(name.size() - 22, 22, "-deduplication-map.txt") == 0) ||
          (name.size() >= 12 &&
           name.compare(name.size() - 12, 12, "-TLP-hlo.txt") == 0))
        paths.insert(it->path().string());
    }
    if (error) return absl::UnavailableError(error.message());
    return paths;
  };
  ABSL_ASSIGN_OR_RETURN(auto before, final_bundles());
  CompileOptions options = input.options;
  options.executable_build_options.mutable_debug_options();
  ABSL_ASSIGN_OR_RETURN(auto proto, options.ToProto());
  const std::string serialized = proto.SerializeAsString();
  PJRT_Program program{};
  program.struct_size = PJRT_Program_STRUCT_SIZE;
  program.code = const_cast<char*>(input.code.data());
  program.code_size = input.code.size();
  program.format = input.format.data();
  program.format_size = input.format.size();
  PJRT_Compile_Args compile{};
  compile.struct_size = PJRT_Compile_Args_STRUCT_SIZE;
  compile.topology = artifacts.topology;
  compile.program = &program;
  compile.compile_options = serialized.data();
  compile.compile_options_size = serialized.size();
  ABSL_RETURN_IF_ERROR(Consume(api, api->PJRT_Compile(&compile)));
  artifacts.executable = compile.executable;

  ABSL_ASSIGN_OR_RETURN(auto after, final_bundles());
  std::vector<std::string> fresh;
  std::set_difference(after.begin(), after.end(), before.begin(), before.end(),
                      std::back_inserter(fresh));
  if (fresh.empty())
    return absl::FailedPreconditionError(
        absl::StrCat("libtpu produced no Final LLO bundles in ", dump_dir,
                     "; no assembly or HLO fallback."));
  return EstimateFinalBundles(fresh);
}
}  // namespace xla::sim
