#ifndef XLA_PJRT_SIM_EXECUTABLE_WORK_H_
#define XLA_PJRT_SIM_EXECUTABLE_WORK_H_

#include <cstdint>

#include "src/bundle_timing.h"

namespace xla::sim {
// Immutable executable metadata retained after compilation and snapshot export.
struct ExecutableWork {
  BundleTiming bundle_timing;
  int64_t substituted_ops = 0;
  uint64_t program_id = 0;
  int64_t num_replicas = 1;
  int64_t num_partitions = 1;
};

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_EXECUTABLE_WORK_H_
