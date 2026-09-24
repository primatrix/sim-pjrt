#ifndef XLA_PJRT_SIM_RAW_BUFFER_H_
#define XLA_PJRT_SIM_RAW_BUFFER_H_

#include "src/runtime.h"
#include "xla/pjrt/pjrt_client.h"
#include "xla/pjrt/raw_buffer.h"

namespace xla::sim {
// Retains physical storage, but exposes logical size and placeholder semantics.
absl::StatusOr<PjRtRawBufferRef> MakeRawAlias(
    PjRtBuffer* storage, int64_t bytes, bool placeholder,
    std::shared_ptr<SimRuntime> runtime, Completion ready);
}  // namespace xla::sim
#endif
