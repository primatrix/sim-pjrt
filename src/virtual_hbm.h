#ifndef XLA_PJRT_SIM_VIRTUAL_HBM_H_
#define XLA_PJRT_SIM_VIRTUAL_HBM_H_

#include <cstdint>
#include <memory>

#include "absl/status/status.h"
#include "absl/status/statusor.h"
#include "src/raw_buffer.h"
#include "src/memory.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/pjrt_client.h"

namespace xla::sim {
// Virtual HBM has no payload-size threshold. Floating payloads use scalar
// placeholders; integer, boolean and single-value float control state uses
// host shadow storage.
absl::Status VirtualizeModule(HloModule &module);
absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>>
CompileVirtual(PjRtClient *client, std::unique_ptr<HloModule> module,
               CompileOptions options, std::shared_ptr<MemoryBudget> memory = {});
PJRT_Error *VirtualFromHost(PJRT_Client_BufferFromHostBuffer_Args *args,
                           std::shared_ptr<MemoryBudget> memory);
std::shared_ptr<MemoryAllocation> VirtualAllocation(PjRtBuffer* buffer);
absl::StatusOr<PjRtRawBufferRef> VirtualRawAlias(
    PjRtBuffer* buffer, std::shared_ptr<SimRuntime> runtime, Completion ready);
// Reject pointer export that would expose scalar backing as logical storage.
// Host reads instead materialize simulated data through the buffer's D2H APIs.
absl::Status CheckMaterialized(PjRtBuffer *buffer);
} // namespace xla::sim
#endif // XLA_PJRT_SIM_VIRTUAL_HBM_H_
