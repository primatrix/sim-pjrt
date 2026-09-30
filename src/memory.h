#ifndef XLA_PJRT_SIM_MEMORY_H_
#define XLA_PJRT_SIM_MEMORY_H_

#include <cstdint>
#include <map>
#include <memory>
#include <mutex>

#include "absl/status/statusor.h"

namespace xla::sim {
class MemoryBudget;

// One logical allocation. Buffer aliases and pending work share its lifetime.
struct MemoryAllocation {
  std::shared_ptr<MemoryBudget> budget;
  int64_t device;
  int64_t bytes;
  ~MemoryAllocation();
};

struct MemoryUsage {
  int64_t used = 0;
  int64_t peak = 0;
  int64_t allocations = 0;
};

class MemoryBudget : public std::enable_shared_from_this<MemoryBudget> {
 public:
  MemoryBudget(int64_t capacity, int64_t reserved)
      : capacity_(capacity), reserved_(reserved) {}
  absl::StatusOr<std::shared_ptr<MemoryAllocation>> Allocate(int64_t device,
                                                          int64_t bytes);
  MemoryUsage Stats(int64_t device) const;
  int64_t capacity() const { return capacity_; }

 private:
  friend struct MemoryAllocation;
  void Release(int64_t device, int64_t bytes);
  const int64_t capacity_;
  const int64_t reserved_;
  mutable std::mutex mutex_;
  std::map<int64_t, MemoryUsage> devices_;
};
}  // namespace xla::sim
#endif
