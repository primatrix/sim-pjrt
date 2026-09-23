#ifndef XLA_PJRT_SIM_BUNDLE_TIMING_H_
#define XLA_PJRT_SIM_BUNDLE_TIMING_H_

#include <cstdint>
#include <string>
#include <vector>

#include "absl/status/statusor.h"

namespace xla::sim {
struct BundleTiming {
  int64_t duration_ns = 0;
  int64_t bundles = 0;
  int64_t cost_gaps = 0;
};

struct BundleCompilation {
  BundleTiming timing;
  std::string report_json;
};

// Process-private libtpu dump directory, created before plugin initialization.
const absl::StatusOr<std::string>& BundleDumpDirectory();
// IO boundary around the pure Python model; no HLO is read or constructed.
absl::StatusOr<BundleCompilation> EstimateFinalBundles(
    const std::vector<std::string>& files);
}  // namespace xla::sim
#endif
