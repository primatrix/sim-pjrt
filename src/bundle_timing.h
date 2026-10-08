#ifndef XLA_PJRT_SIM_BUNDLE_TIMING_H_
#define XLA_PJRT_SIM_BUNDLE_TIMING_H_

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

#include "absl/status/statusor.h"

namespace xla::sim {
// Offsets within one executable; overlapping tracks describe the same work.
struct BundleActivity {
  std::string name;
  std::string track;
  std::string detail;
  std::string hlo_text;
  std::string tf_op;
  std::string source;
  std::string source_stack;
  std::string source_status;
  std::string source_stack_status;
  std::string source_revision;
  std::string cost_gap;
  int64_t start_ns = 0;
  int64_t end_ns = 0;
  int64_t bytes = -1;
  int64_t sparse_core = -1;
  // Ordinal in ascending captured device ID order; -1 broadcasts LLO activities.
  int64_t device_index = -1;
};

struct BundleTiming {
  std::string analysis_source = "libtpu_bundles";
  int64_t duration_ns = 0;
  int64_t bundles = 0;
  int64_t cost_gaps = 0;
  // Shared immutable metadata avoids copying the timeline on every dispatch.
  std::shared_ptr<const std::vector<BundleActivity>> activities =
      std::make_shared<const std::vector<BundleActivity>>();
};

struct BundleCompilation {
  BundleTiming timing;
  std::string report_json;
};

// Dump-only mode exports compiler artifacts and skips all modeled delays.
bool DumpOnly();
// Process-private libtpu dump directory, created before plugin initialization.
const absl::StatusOr<std::string>& BundleDumpDirectory();
// Write a compilation manifest; estimate timing unless dump-only mode is active.
absl::StatusOr<BundleCompilation> FinalizeBundles(
    const std::vector<std::string>& files);
// Read a measured prediction attached to the compile input by the launcher.
// Replay can retain the original per-device event timeline from a TPU capture.
absl::StatusOr<BundleCompilation> ReadReplayTiming(const std::string& json);
}  // namespace xla::sim
#endif
