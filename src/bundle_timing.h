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
  int64_t duration_ns = 0;
  int64_t bundles = 0;
  int64_t cost_gaps = 0;
  // Boolean scalar input indices, with little-endian bitmask case selection.
  std::vector<int64_t> branch_parameters;
  std::vector<std::shared_ptr<const BundleTiming>> branch_cases;
  // Shared immutable metadata avoids copying the timeline on every dispatch.
  std::shared_ptr<const std::vector<BundleActivity>> activities =
      std::make_shared<const std::vector<BundleActivity>>();
};

struct BundleCompilation {
  BundleTiming timing;
  std::string report_json;
};

// Process-private libtpu dump directory, created before plugin initialization.
const absl::StatusOr<std::string>& BundleDumpDirectory();
// Final LLO timing with optional SparseCore calibration and compiler labels.
absl::StatusOr<BundleCompilation> EstimateFinalBundles(
    const std::vector<std::string>& files);
}  // namespace xla::sim
#endif
