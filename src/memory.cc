#include "src/memory.h"

#include <algorithm>

#include "absl/strings/str_cat.h"

namespace xla::sim {
MemoryAllocation::~MemoryAllocation() { budget->Release(device, bytes); }

absl::StatusOr<std::shared_ptr<MemoryAllocation>> MemoryBudget::Allocate(
    int64_t device, int64_t bytes) {
  std::lock_guard<std::mutex> lock(mutex_);
  auto& stats = devices_[device];
  if (bytes < 0 || bytes > capacity_ - reserved_ - stats.used)
    return absl::ResourceExhaustedError(absl::StrCat(
        "Virtual HBM OOM on device ", device, ": requested ", bytes,
        " bytes; used ", stats.used, ", reserved ", reserved_,
        ", capacity ", capacity_));
  stats.used += bytes;
  stats.peak = std::max(stats.peak, stats.used);
  ++stats.allocations;
  return std::shared_ptr<MemoryAllocation>(
      new MemoryAllocation{shared_from_this(), device, bytes});
}

void MemoryBudget::Release(int64_t device, int64_t bytes) {
  std::lock_guard<std::mutex> lock(mutex_);
  devices_.at(device).used -= bytes;
}

MemoryUsage MemoryBudget::Stats(int64_t device) const {
  std::lock_guard<std::mutex> lock(mutex_);
  const auto found = devices_.find(device);
  MemoryUsage stats = found == devices_.end() ? MemoryUsage{} : found->second;
  // Reserved capacity is unavailable to application buffers from startup.
  stats.used += reserved_;
  stats.peak += reserved_;
  return stats;
}
}  // namespace xla::sim
