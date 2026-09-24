#ifndef XLA_PJRT_SIM_INSTRUMENTATION_H_
#define XLA_PJRT_SIM_INSTRUMENTATION_H_

#include <cstdint>
#include <string>

#include "src/executable_work.h"
#include "src/runtime.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/c/pjrt_c_api_raw_buffer_extension.h"

namespace xla::sim {
// Accounts for live logical buffers and emits per-execution work to JSONL when
// PJRT_SIM_TRACE is set. Each process writes <prefix>.<pid>.jsonl.
void AddInstrumentation(PJRT_Api& api);
PJRT_RawBuffer_Extension RawBufferExtension(PJRT_Extension_Base* next);
void RegisterRuntime(PJRT_Client* client, RuntimeConfig config);
void RegisterWork(PJRT_LoadedExecutable* executable, ExecutableWork work,
                  const std::string& program_json = {});
}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_INSTRUMENTATION_H_
