#include "src/raw_buffer.h"

#include <cstring>
#include <mutex>
#include <utility>

#include "absl/status/status_macros.h"
#include "xla/pjrt/common_pjrt_client.h"
#include "xla/pjrt/cpu/raw_buffer.h"
#include "xla/pjrt/device_event_utils.h"

namespace xla::sim {
namespace {
// Slices share ordering and retain the allocation independently of PJRT_Buffer.
struct RawState {
  std::mutex mutex;
  std::shared_ptr<SimRuntime> runtime;
  Completion tail;
};

class RawAlias final : public CommonPjRtRawBufferImpl {
 public:
  RawAlias(PjRtRawBufferRef storage, int64_t bytes, bool placeholder,
           int64_t device, std::shared_ptr<RawState> state,
           PjRtDeviceEventRef allocated)
      : storage_(std::move(storage)), bytes_(bytes), placeholder_(placeholder),
        device_(device), state_(std::move(state)), allocated_(std::move(allocated)) {}

  PjRtMemorySpace* memory_space() const override { return storage_->memory_space(); }
  size_t GetOnDeviceSizeInBytes() const override { return bytes_; }
  // Never expose scalar backing as a pointer to the logical payload. Transfers
  // must also honor readiness, so direct pointers are unavailable for all aliases.
  void* OpaqueDeviceMemoryDataPointer() const override { return nullptr; }
  bool is_mutable() const override { return placeholder_ || storage_->is_mutable(); }
  absl::StatusOr<PjRtDeviceEventRef> MakeAllocationReadyEvent() override {
    return allocated_;
  }
  PjRtDeviceEventPtr GetRawBufferAsyncValue() override { return allocated_.ptr(); }

  absl::StatusOr<PjRtRawBufferRef> Slice(int64_t offset, int64_t size) override {
    ABSL_RETURN_IF_ERROR(CheckRange(offset, size));
    auto storage = storage_;
    if (!placeholder_) {
      ABSL_ASSIGN_OR_RETURN(storage, storage_->Slice(offset, size));
    }
    return tsl::MakeRef<RawAlias>(std::move(storage), size, placeholder_, device_,
                                  state_, allocated_);
  }

  absl::StatusOr<PjRtDeviceEventRef> CopyRawHostToDeviceAndReturnEvent(
      const void* src, int64_t offset, int64_t size,
      PjRtDeviceEventRefVector dependencies) override {
    return Transfer(src, nullptr, offset, size, true, std::move(dependencies));
  }
  absl::StatusOr<PjRtDeviceEventRef> CopyRawDeviceToHostAndReturnEvent(
      void* dst, int64_t offset, int64_t size,
      PjRtDeviceEventRefVector dependencies) override {
    return Transfer(nullptr, dst, offset, size, false, std::move(dependencies));
  }

  void CopyTo(PjRtRawBufferRef, PjRtDeviceEventPromiseRef defined,
              PjRtDeviceEventPromiseRef used,
              absl::AnyInvocable<void(absl::Status) &&> allocated) override {
    auto error = absl::UnimplementedError(
        "Raw device-to-device copy is unsupported; use host-staged transfers");
    std::move(allocated)(error);
    defined.SetError(error);
    used.SetError(error);
  }

 private:
  absl::Status CheckRange(int64_t offset, int64_t size) const {
    if (offset < 0 || size < 0 || offset > bytes_ || size > bytes_ - offset)
      return absl::InvalidArgumentError("RawBuffer transfer range is invalid");
    return absl::OkStatus();
  }
  absl::StatusOr<PjRtDeviceEventRef> Transfer(
      const void* src, void* dst, int64_t offset, int64_t size, bool h2d,
      PjRtDeviceEventRefVector dependencies) {
    ABSL_RETURN_IF_ERROR(CheckRange(offset, size));
    if (size && !(h2d ? src : dst))
      return absl::InvalidArgumentError("RawBuffer transfer pointer is null");
    if (h2d && !is_mutable())
      return absl::FailedPreconditionError("RawBuffer is not mutable");
    ProfileCall profile(h2d ? "PJRT raw H2D submit" : "PJRT raw D2H submit");
    auto [promise, data_ready] = MakePromise();
    Completion completion;
    {
      std::lock_guard<std::mutex> lock(state_->mutex);
      dependencies.push_back(ToCpuEvent(state_->tail.future));
      completion = state_->runtime
          ? state_->runtime->Transfer(h2d ? -1 : device_, h2d ? device_ : -1,
                                      size, state_->tail, profile.activity())
          : state_->tail;
      completion.future = JoinFutures({completion.future, data_ready});
      state_->tail = completion;
    }
    // Callbacks can run inline. Never register them while holding the state lock.
    RunWhenReady(dependencies,
        [self = tsl::FormRef(this), dependencies, src, dst, offset, size, h2d,
         promise = std::move(promise)]() mutable {
          auto status = GetErrors(dependencies);
          if (!status.ok() || !size || self->placeholder_) {
            if (status.ok() && !h2d && size) std::memset(dst, 0, size);
            promise.Set(status);
            return;
          }
          auto copy = h2d ? self->storage_->CopyRawHostToDevice(src, offset, size)
                          : self->storage_->CopyRawDeviceToHost(dst, offset, size);
          copy.OnReady([self, promise = std::move(promise)](absl::Status status) mutable {
            promise.Set(status);
          });
        });
    profile.activity().Ready(completion.future,
        h2d ? "Raw H2D submit-to-ready" : "Raw D2H submit-to-ready", device_, 0, size);
    return ToCpuEvent(completion.future);
  }

  PjRtRawBufferRef storage_;
  int64_t bytes_;
  bool placeholder_;
  int64_t device_;
  std::shared_ptr<RawState> state_;
  PjRtDeviceEventRef allocated_;
};
}  // namespace

absl::StatusOr<PjRtRawBufferRef> MakeRawAlias(
    PjRtBuffer* storage, int64_t bytes, bool placeholder,
    std::shared_ptr<SimRuntime> runtime, Completion ready) {
  if (storage->IsDeleted())
    return absl::InvalidArgumentError("Cannot alias a deleted buffer");
  ready.future = JoinFutures({ready.future, storage->GetReadyFuture()});
  ABSL_ASSIGN_OR_RETURN(auto raw, PjRtRawBuffer::CreateRawAliasOfBuffer(storage));
  auto state = std::make_shared<RawState>();
  state->runtime = std::move(runtime);
  state->tail = ready;
  return tsl::MakeRef<RawAlias>(std::move(raw), bytes, placeholder,
      storage->device()->id(), std::move(state), ToCpuEvent(ready.future));
}
}  // namespace xla::sim
