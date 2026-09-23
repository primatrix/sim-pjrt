// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#ifndef XLA_PJRT_SIM_PARTITIONING_H_
#define XLA_PJRT_SIM_PARTITIONING_H_
#include "absl/status/status.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/pjrt/pjrt_client.h"
namespace xla::sim {
// Run XLA's normal partitioning before storage substitution. The resulting
// module has local shapes and explicit collectives; its SPMD metadata retains
// the global input/output shardings. Prevent CPU compilation partitioning
// twice.
absl::Status PartitionForVirtualStorage(HloModule& module,
                                        CompileOptions& options);
}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_PARTITIONING_H_
