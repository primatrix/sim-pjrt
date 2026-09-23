#ifndef XLA_PJRT_SIM_VIRTUAL_STORAGE_H_
#define XLA_PJRT_SIM_VIRTUAL_STORAGE_H_

#include <cstdint>
#include <memory>

#include "absl/status/status.h"
#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/c/pjrt_c_api.h"
#include "xla/pjrt/pjrt_client.h"

namespace xla::sim {
// Zero disables virtual storage. Otherwise large static floating arrays use a
// scalar backing buffer; nonfloating arrays must fit the per-array limit.
absl::Status VirtualizeModule(HloModule& module, int64_t limit);
absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>> CompileVirtual(
    PjRtClient* client, std::unique_ptr<HloModule> module,
    CompileOptions options, int64_t limit);
PJRT_Error* VirtualFromHost(PJRT_Client_BufferFromHostBuffer_Args* args,
                            int64_t limit);
// Reject before host size queries or pointer export can expose scalar storage.
absl::Status CheckMaterialized(PjRtBuffer* buffer);
}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_VIRTUAL_STORAGE_H_
