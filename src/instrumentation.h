#ifndef XLA_PJRT_SIM_INSTRUMENTATION_H_
#define XLA_PJRT_SIM_INSTRUMENTATION_H_

#include <cstdint>
#include <memory>
#include <string>

#include "xla/pjrt/c/pjrt_c_api.h"
#include "src/hlo_model.h"
#include "src/runtime.h"

namespace xla::sim {
// Immutable executable metadata retained after compilation and snapshot export.
struct ExecutableWork {
  std::shared_ptr<const ExecutionPlan> plan;
  WorkEstimate estimate;
  bool partitioned = false;
  uint64_t program_id = 0;
  int64_t num_replicas = 1;
  int64_t num_partitions = 1;
};

// Accounts for live logical buffers and emits per-execution work to JSONL when
// PJRT_SIM_TRACE is set. Each process writes <prefix>.<pid>.jsonl.
void AddInstrumentation(PJRT_Api& api);
void RegisterRuntime(PJRT_Client* client, RuntimeConfig config);
int64_t MaxMaterializedBytes(PJRT_Client* client);
void RegisterWork(PJRT_LoadedExecutable* executable, ExecutableWork work,
                  const std::string& program_json = {});
}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_INSTRUMENTATION_H_
