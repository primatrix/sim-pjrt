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
  std::string cost_gap;
  int64_t start_ns = 0;
  int64_t end_ns = 0;
  int64_t bytes = -1;
  int64_t sparse_core = -1;
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
// Replay contains only a module duration, never a fabricated bundle timeline.
absl::StatusOr<BundleCompilation> ReadReplayTiming(const std::string& json);
}  // namespace xla::sim
#endif
