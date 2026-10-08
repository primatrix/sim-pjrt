#include "src/compilation.h"

#include <cstdlib>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "mlir/IR/MLIRContext.h"
#include "src/output_simulation.h"
#include "src/partitioning.h"
#include "src/tpu_compilation.h"
#include "src/virtual_hbm.h"
#include "xla/hlo/builder/xla_computation.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/mlir_to_hlo.h"

namespace xla::sim {
namespace {

absl::StatusOr<std::unique_ptr<HloModule>>
LowerToHlo(const CompilationInput &input, CompileOptions &options,
           std::string& prediction, ExecutableWork& work, std::string& clean_code) {
  XlaComputation computation;
  const auto format = input.format;
  if (format == "mlir") {
    mlir::MLIRContext context;
    ABSL_ASSIGN_OR_RETURN(auto module,
                          ParseMlirModuleString(input.code, context));
    if (auto timing = (*module)->getAttrOfType<mlir::StringAttr>("sim_pjrt.timing")) {
      prediction = timing.getValue().str();
      (*module)->removeAttr("sim_pjrt.timing");
    }
    if (auto key = (*module)->getAttrOfType<mlir::StringAttr>("sim_pjrt.execution_key")) {
      work.execution_key = key.getValue().str();
      (*module)->removeAttr("sim_pjrt.execution_key");
    }
    if (auto miss = (*module)->getAttrOfType<mlir::BoolAttr>("sim_pjrt.replay_miss")) {
      work.replay_miss = miss.getValue();
      (*module)->removeAttr("sim_pjrt.replay_miss");
    }
    if (!work.execution_key.empty() || !prediction.empty() || work.replay_miss) {
      llvm::raw_string_ostream stream(clean_code);
      (*module)->print(stream, mlir::OpPrintingFlags().enableDebugInfo());
    }
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

} // namespace

absl::StatusOr<CompiledProgram> CompileProgram(const CompilationInput &input,
                                               PjRtClient *output_client,
                                               bool capture_snapshot,
                                               std::shared_ptr<MemoryBudget> memory) {
  // Output lowering and partitioning may change these options. Never modify
  // the original options needed by another compiler backend.
  CompileOptions options = input.options;
  // Direct callers may omit debug options; initialize defaults on the copy.
  options.executable_build_options.mutable_debug_options();
  const auto &build = options.executable_build_options;
  if (build.num_replicas() * build.num_partitions() >
      output_client->addressable_device_count()) {
    return absl::InvalidArgumentError(
        "Executable needs more devices than PJRT_SIM_DEVICE_COUNT");
  }
  std::string prediction;
  std::string clean_code;
  CompiledProgram result;
  ABSL_ASSIGN_OR_RETURN(auto module, LowerToHlo(input, options, prediction, result.work, clean_code));
  const bool partitioned = build.num_partitions() > 1;
  if (partitioned) {
    ABSL_RETURN_IF_ERROR(PartitionForVirtualHbm(*module, options));
  }

  const char* selected = std::getenv("PJRT_SIM_PREDICTOR");
  const char* miss_policy = std::getenv("PJRT_SIM_REPLAY_MISS");
  const bool fallback = result.work.replay_miss && miss_policy &&
                        std::string(miss_policy) == "llo";
  const bool replay = !DumpOnly() && selected && std::string(selected) == "replay" && !fallback;
  if (selected && *selected && std::string(selected) != "llo" &&
      std::string(selected) != "replay")
    return absl::InvalidArgumentError("Unknown PJRT_SIM_PREDICTOR");
  if (replay && prediction.empty())
    return absl::FailedPreconditionError(
        "Replay requires executable metadata; use spjrt run --predictor replay --database FILE");
  CompilationInput clean = input;
  // Simulator annotations never reach the TPU compiler or its cache key.
  if (!clean_code.empty()) clean.code = clean_code;
  ABSL_ASSIGN_OR_RETURN(
      auto timing, replay ? ReadReplayTiming(prediction)
                          : CompileTpuBundles(clean, std::getenv("PJRT_SIM_LIBTPU_PATH"),
                                              std::getenv("PJRT_SIM_TPU_TOPOLOGY")));
  result.work.num_replicas = build.num_replicas();
  result.work.num_partitions = build.num_partitions();
  if (replay && !timing.timing.activities->empty()) {
    int64_t modules = 0;
    for (const auto& activity : *timing.timing.activities)
      modules += activity.track == "XLA Modules";
    if (modules != build.num_replicas() * build.num_partitions())
      return absl::InvalidArgumentError("Replay timeline device count differs from executable");
  }
  if (capture_snapshot)
    result.program_json = std::move(timing.report_json);
  result.work.bundle_timing = timing.timing;

  // Analysis and snapshots must observe the program before output substitution.
  ABSL_ASSIGN_OR_RETURN(result.work.substituted_ops,
                        SubstituteSimulationOutputs(*module));
  ABSL_ASSIGN_OR_RETURN(
      result.executable,
      CompileVirtual(output_client, std::move(module), std::move(options),
                     std::move(memory)));
  return result;
}

} // namespace xla::sim
