#ifndef XLA_PJRT_SIM_OUTPUT_SIMULATION_H_
#define XLA_PJRT_SIM_OUTPUT_SIMULATION_H_

#include <cstdint>

#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"

namespace xla::sim {

// Replaces floating dots and recognized TPU kernels with deterministic outputs.
// Preserves integer control values and aliases; rejects unknown custom calls
// and kernel side effects. Returns the number of replaced operations.
// This mutates the output program only and performs no performance analysis.
absl::StatusOr<int64_t> SubstituteSimulationOutputs(HloModule& module);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_OUTPUT_SIMULATION_H_
