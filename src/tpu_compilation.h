#ifndef XLA_PJRT_SIM_TPU_COMPILATION_H_
#define XLA_PJRT_SIM_TPU_COMPILATION_H_

#include <array>
#include <memory>
#include <string>
#include <vector>

#include "absl/status/statusor.h"
#include "src/bundle_timing.h"
#include "src/compilation.h"

namespace xla::sim {
struct TpuDeviceDescription {
  int id;
  std::array<int64_t, 3> coords{};
  int64_t core_on_chip = 0;
};
struct TpuTopology {
  std::string kind;
  std::vector<TpuDeviceDescription> devices;
};
// Match frontend Pallas lowering and mesh construction to the compiler target.
absl::StatusOr<TpuTopology> DescribeTpuTopology(const char* library,
                                                const char* topology);
// Compile the untouched input with libtpu's offline PJRT compiler. No TPU
// client or physical device is created. Export Final LLO and optionally estimate
// its timing; TPU HLO is only used for metadata.
absl::StatusOr<BundleCompilation> CompileTpuBundles(
    const CompilationInput& input, const char* library, const char* topology);
}  // namespace xla::sim
#endif
