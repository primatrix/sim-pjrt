#ifndef XLA_PJRT_SIM_HLO_MODEL_H_
#define XLA_PJRT_SIM_HLO_MODEL_H_

#include <cstdint>

#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"

namespace xla::sim {

// Work measured BEFORE numerical substitutions. Logical bytes are not measured
// HBM traffic. Opaque kernels and dynamic control flow make timing incomplete.
struct WorkEstimate {
  double dot_flops = 0;
  double logical_bytes = 0;
  int64_t substituted_ops = 0;
  int64_t unmodeled_ops = 0;
};

// Replaces floating point dots and explicitly recognized TPU kernels with
// deterministic placeholders. Other operations retain their actual semantics,
// including integer indexing and host-visible control values. Unknown custom
// calls fail closed. This is a functional simulation, not TPU code generation.
absl::StatusOr<WorkEstimate> PrepareForSimulation(HloModule& module);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_HLO_MODEL_H_
