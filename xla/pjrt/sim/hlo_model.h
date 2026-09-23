/* Copyright 2026 The OpenXLA Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/
#ifndef XLA_PJRT_SIM_HLO_MODEL_H_
#define XLA_PJRT_SIM_HLO_MODEL_H_

#include <cstdint>

#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_module.h"

namespace xla::sim {

// Work measured BEFORE numerical substitutions. Logical bytes are not measured
// HBM traffic. Opaque kernels and dynamic control flow make timing incomplete.
struct WorkEstimate {
  double dot_flops = 0;
  double logical_bytes = 0;
  int64_t substituted_ops = 0;
  int64_t unmodeled_ops = 0;
};

// Replaces floating point dots and explicitly recognized TPU kernels with
// deterministic placeholders. Other operations retain their actual semantics,
// including integer indexing and host-visible control values. Unknown custom
// calls fail closed. This is a functional simulation, not TPU code generation.
absl::StatusOr<WorkEstimate> PrepareForSimulation(HloModule& module);

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_HLO_MODEL_H_
