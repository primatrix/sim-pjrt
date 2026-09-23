// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#ifndef XLA_PJRT_SIM_PROGRAM_SNAPSHOT_H_
#define XLA_PJRT_SIM_PROGRAM_SNAPSHOT_H_

#include <cstdint>
#include <string>

#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"
#include "src/execution_plan.h"

namespace xla::sim {
// Capture before numerical substitutions. HLO permits offline replanning for
// another device count; the embedded plan needs no native tool to replay.
absl::StatusOr<std::string> CaptureProgramSnapshot(const HloModule& module,
                                                   const ExecutionPlan& plan,
                                                   int64_t devices,
                                                   bool partitioned);

// Serialize the same immutable plan consumed by SimRuntime. Costs are per
// device and independent of hardware rates, routing, and physical device IDs.
absl::StatusOr<std::string> SerializeExecutionPlan(const ExecutionPlan& plan,
                                                   int64_t devices);
}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_PROGRAM_SNAPSHOT_H_
