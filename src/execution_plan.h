#ifndef XLA_PJRT_SIM_EXECUTION_PLAN_H_
#define XLA_PJRT_SIM_EXECUTION_PLAN_H_

#include <cstdint>
#include <string>
#include <utility>
#include <vector>

#include "xla/hlo/ir/hlo_module.h"

namespace xla::sim {

// A topologically ordered, immutable plan from original HLO. Device numbers
// are executable-local ordinals, bound to physical devices at submission.
struct PlanNode {
  enum class Kind {
    kBarrier,
    kCompute,
    kAllReduce,
    kAllGather,
    kReduceScatter,
    kTransfers
  };
  // -1 identifies scheduling-only barriers and inferred communication.
  int64_t hlo_id = -1;
  std::string opcode;
  std::string dtype;
  bool inferred = false;
  std::string name;
  std::string framework_op;
  std::string cost_gap;
  std::string cost_source;
  Kind kind = Kind::kBarrier;
  std::vector<int> dependencies;
  // Directed executable-local device pairs; bytes is the payload per pair.
  std::vector<std::pair<int, int>> transfers;
  double flops = 0;
  double transcendentals = 0;
  double bytes = 0;
  double read_bytes = 0;
  double write_bytes = 0;
};

struct ExecutionPlan {
  std::vector<PlanNode> nodes;
  int root = -1;
  int64_t cost_gaps = 0;
  // Per-device declared kernel totals, computed once while building the plan.
  double kernel_flops = 0;
  double kernel_transcendentals = 0;
  double kernel_bytes = 0;
};

// Intentionally limited to uniform sharding and static calls. Unsupported work
// preserves dependencies and is explicitly marked, never divided by TP blindly.
// partitioned means shapes already describe one device; do not divide them
// again.
ExecutionPlan BuildExecutionPlan(const HloModule& module, int64_t devices,
                                 bool partitioned = false);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_EXECUTION_PLAN_H_
