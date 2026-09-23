#ifndef XLA_PJRT_SIM_RUNTIME_H_
#define XLA_PJRT_SIM_RUNTIME_H_

#include <condition_variable>
#include <cstdint>
#include <map>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <thread>
#include <vector>

#include "absl/status/statusor.h"
#include "src/bundle_timing.h"
#include "src/profiler.h"
#include "xla/future.h"

namespace xla::sim {

struct RuntimeConfig {
  bool simulate_timing = true;
  double host_bytes_per_second = 32e9;
  double link_bytes_per_second = 100e9;
  int64_t launch_ns = 1000;
  int64_t transfer_ns = 2000;
  int64_t link_ns = 1000;
  double communication_scale = 1;
  static absl::StatusOr<RuntimeConfig> FromProfile(absl::string_view json);
  static absl::StatusOr<RuntimeConfig> FromEnvironment();
};

// Modeled completion and host-observable readiness are deliberately separate:
// the latter also requires the CPU functional backend to have produced data.
struct Completion {
  int64_t end_ns = 0;  // steady clock nanoseconds
  Future<> future = Future<>(absl::OkStatus());
};

class SimRuntime {
 public:
  explicit SimRuntime(RuntimeConfig config);
  ~SimRuntime();
  SimRuntime(const SimRuntime&) = delete;
  SimRuntime& operator=(const SimRuntime&) = delete;

  std::vector<Completion> ExecuteTimed(
      int64_t duration_ns, bool partial, const std::vector<int64_t>& devices,
      const std::vector<Completion>& inputs, const ProfileActivity& profile,
      const std::string& name,
      std::shared_ptr<const std::vector<BundleActivity>> activities = {});
  Completion Transfer(int64_t source, int64_t destination, int64_t bytes,
                      const Completion& input, const ProfileActivity& profile);

 private:
  struct Timer {
    int64_t deadline;
    uint64_t sequence;
    std::shared_ptr<Promise<>> promise;
    bool operator<(const Timer& other) const {
      return deadline != other.deadline ? deadline > other.deadline
                                        : sequence > other.sequence;
    }
  };
  Completion CompleteAt(int64_t end);
  void Run();
  int64_t Reserve(int64_t start, int64_t duration,
                  const std::vector<std::string>& resources);
  int64_t Epoch(int64_t steady_ns) const { return steady_ns + epoch_offset_; }

  const RuntimeConfig config_;
  const int64_t epoch_offset_;
  std::mutex mutex_;
  std::condition_variable changed_;
  bool stopping_ = false;
  uint64_t sequence_ = 0;
  std::map<std::string, int64_t> resources_;
  std::map<int64_t, Completion> execution_tail_;
  std::priority_queue<Timer> timers_;
  std::thread worker_;
};

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_RUNTIME_H_
