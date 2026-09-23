#ifndef XLA_PJRT_SIM_COMPILATION_H_
#define XLA_PJRT_SIM_COMPILATION_H_

#include <cstdint>
#include <memory>
#include <string>

#include "absl/status/statusor.h"
#include "absl/strings/string_view.h"
#include "src/executable_work.h"
#include "xla/pjrt/pjrt_client.h"

namespace xla::sim {

// Borrowed serialized input, valid for the synchronous CompileProgram call.
// Keep MLIR (including StableHLO) intact at this boundary so a TPU compiler can
// consume it directly. HLO input is a serialized HloModuleProto, not HLO text.
struct CompilationInput {
  absl::string_view format;
  absl::string_view code;
  CompileOptions options;
};

struct CompiledProgram {
  std::unique_ptr<PjRtLoadedExecutable> executable;
  ExecutableWork work;
  std::string program_json;
};

// Compile original input with libtpu and estimate expanded bundle timing.
// Independently compile virtual simulated outputs on the CPU backend.
absl::StatusOr<CompiledProgram> CompileProgram(const CompilationInput &input,
                                               PjRtClient *output_client,
                                               bool capture_snapshot);

} // namespace xla::sim
#endif // XLA_PJRT_SIM_COMPILATION_H_
