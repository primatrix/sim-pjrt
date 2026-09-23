#ifndef XLA_PJRT_SIM_VIRTUAL_HBM_H_
#define XLA_PJRT_SIM_VIRTUAL_HBM_H_

#include <cstdint>
#include <memory>

#include "absl/status/status.h"
#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/pjrt_client.h"

namespace xla::sim {
// Virtual HBM has no payload-size threshold. Floating payloads use scalar
// placeholders; integer and boolean control values have host shadow storage.
absl::Status VirtualizeModule(HloModule &module);
absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>>
CompileVirtual(PjRtClient *client, std::unique_ptr<HloModule> module,
               CompileOptions options);
PJRT_Error *VirtualFromHost(PJRT_Client_BufferFromHostBuffer_Args *args);
// Reject pointer export that would expose scalar backing as logical storage.
// Host reads instead materialize simulated data through the buffer's D2H APIs.
absl::Status CheckMaterialized(PjRtBuffer *buffer);
} // namespace xla::sim
#endif // XLA_PJRT_SIM_VIRTUAL_HBM_H_
