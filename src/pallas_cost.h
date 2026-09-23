#ifndef XLA_PJRT_SIM_PALLAS_COST_H_
#define XLA_PJRT_SIM_PALLAS_COST_H_

#include "absl/status/status.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "src/execution_plan.h"

namespace xla::sim {

// Consume the kernel author's estimate; never infer semantics from its name.
// Counts describe one local invocation, not work divided by device count.
absl::Status EstimatePallas(const HloInstruction& instruction, int64_t devices,
                            bool local, PlanNode& node);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_PALLAS_COST_H_
