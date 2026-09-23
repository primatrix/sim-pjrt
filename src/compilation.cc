#include "src/compilation.h"

#include <cstdlib>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "mlir/IR/MLIRContext.h"
#include "src/output_simulation.h"
#include "src/partitioning.h"
#include "src/tpu_compilation.h"
#include "src/virtual_storage.h"
#include "xla/hlo/builder/xla_computation.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/mlir_to_hlo.h"

namespace xla::sim {
namespace {

absl::StatusOr<std::unique_ptr<HloModule>> LowerToHlo(
    const CompilationInput& input, CompileOptions& options) {
  XlaComputation computation;
  const auto format = input.format;
  if (format == "mlir") {
    mlir::MLIRContext context;
    ABSL_ASSIGN_OR_RETURN(auto module,
                          ParseMlirModuleString(input.code, context));
    ABSL_RETURN_IF_ERROR(MlirToXlaComputation(
        *module, computation, options.parameter_is_tupled_arguments,
        /*return_tuple=*/false, &options.executable_build_options));
  } else if (format == "hlo") {
    HloModuleProto module;
    if (!module.ParseFromString(input.code)) {
      return absl::InvalidArgumentError("Invalid simulator HLO input");
    }
    computation = XlaComputation(module);
  } else {
    return absl::UnimplementedError("Expected MLIR or HLO program");
  }
  ABSL_ASSIGN_OR_RETURN(HloModuleConfig config,
                        HloModule::CreateModuleConfigFromProto(
                            computation.proto(),
                            options.executable_build_options.debug_options()));
  ABSL_ASSIGN_OR_RETURN(
      std::unique_ptr<HloModule> module,
      HloModule::CreateFromProto(computation.proto(), config));
  return module;
}

}  // namespace

absl::StatusOr<CompiledProgram> CompileProgram(const CompilationInput& input,
                                               PjRtClient* output_client,
                                               int64_t storage_limit,
                                               bool capture_snapshot) {
  // Output lowering and partitioning may change these options. Never modify
  // the original options needed by another compiler backend.
  CompileOptions options = input.options;
  // Direct callers may omit debug options; initialize defaults on the copy.
  options.executable_build_options.mutable_debug_options();
  const auto& build = options.executable_build_options;
  if (build.num_replicas() * build.num_partitions() >
      output_client->addressable_device_count()) {
    return absl::InvalidArgumentError(
        "Executable needs more devices than PJRT_SIM_DEVICE_COUNT");
  }
  ABSL_ASSIGN_OR_RETURN(auto module, LowerToHlo(input, options));
  const bool partitioned = storage_limit > 0 && build.num_partitions() > 1;
  if (partitioned) {
    ABSL_RETURN_IF_ERROR(PartitionForVirtualStorage(*module, options));
  }

  CompiledProgram result;
  ABSL_ASSIGN_OR_RETURN(
      auto timing, CompileTpuBundles(input, std::getenv("PJRT_SIM_LIBTPU_PATH"),
                                     std::getenv("PJRT_SIM_TPU_TOPOLOGY")));
  result.work.num_replicas = build.num_replicas();
  result.work.num_partitions = build.num_partitions();
  if (capture_snapshot) result.program_json = std::move(timing.report_json);
  result.work.bundle_timing = timing.timing;

  // Analysis and snapshots must observe the program before output substitution.
  ABSL_ASSIGN_OR_RETURN(result.work.substituted_ops,
                        SubstituteSimulationOutputs(*module));
  if (storage_limit > 0) {
    ABSL_ASSIGN_OR_RETURN(result.executable,
                          CompileVirtual(output_client, std::move(module),
                                         std::move(options), storage_limit));
  } else {
    ABSL_ASSIGN_OR_RETURN(
        result.executable,
        output_client->CompileAndLoad(XlaComputation(module->ToProto()),
                                      std::move(options)));
  }
  return result;
}

}  // namespace xla::sim
