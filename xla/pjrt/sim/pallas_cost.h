// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#ifndef XLA_PJRT_SIM_PALLAS_COST_H_
#define XLA_PJRT_SIM_PALLAS_COST_H_

#include "absl/status/status.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/pjrt/sim/execution_plan.h"

namespace xla::sim {

// Consume the kernel author's estimate; never infer semantics from its name.
// Counts describe one local invocation, not work divided by device count.
absl::Status EstimatePallas(const HloInstruction& instruction, int64_t devices,
                            bool local, PlanNode& node);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_PALLAS_COST_H_
