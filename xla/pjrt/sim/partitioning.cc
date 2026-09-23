// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "xla/pjrt/sim/partitioning.h"

#include "absl/status/status_macros.h"
#include "xla/hlo/transforms/simplifiers/conditional_canonicalizer.h"
#include "xla/hlo/transforms/simplifiers/flatten_call_graph.h"
#include "xla/hlo/transforms/simplifiers/zero_sized_hlo_elimination.h"
#include "xla/service/call_inliner.h"
#include "xla/service/control_dep_rewriter.h"
#include "xla/service/sharding_propagation.h"
#include "xla/service/spmd/shardy/shardy_xla_pass.h"
#include "xla/service/spmd/stateful_rng_spmd_partitioner.h"

namespace xla::sim {
absl::Status PartitionForVirtualStorage(HloModule& module,
                                        CompileOptions& options) {
  auto& build = options.executable_build_options;
  if (build.num_partitions() == 1) return absl::OkStatus();
  if (!build.use_spmd_partitioning() || build.num_replicas() != 1) {
    return absl::UnimplementedError(
        "Virtual partitions require SPMD with one replica");
  }
  if (!build.debug_options().xla_enable_hlo_passes_only().empty()) {
    return absl::InvalidArgumentError(
        "Virtual partitioning cannot use xla_enable_hlo_passes_only");
  }
  auto& config = module.mutable_config();
  config.set_num_partitions(build.num_partitions());
  config.set_replica_count(build.num_replicas());
  config.set_use_spmd_partitioning(true);
  config.set_use_shardy_partitioner(build.use_shardy_partitioner());
  config.set_allow_spmd_sharding_propagation_to_parameters(
      build.allow_spmd_sharding_propagation_to_parameters());
  config.set_allow_spmd_sharding_propagation_to_output(
      build.allow_spmd_sharding_propagation_to_output());
  // Mirror the CPU compiler's partitioning prerequisites without running its
  // floating-point optimizer or allocating buffers at global tensor sizes.
  ABSL_RETURN_IF_ERROR(FlattenCallGraph().Run(&module).status());
  ABSL_RETURN_IF_ERROR(CallInliner().Run(&module).status());
  ABSL_RETURN_IF_ERROR(ZeroSizedHloElimination().Run(&module).status());
  ABSL_RETURN_IF_ERROR(ConditionalCanonicalizer().Run(&module).status());
  if (build.use_shardy_partitioner()) {
    ABSL_RETURN_IF_ERROR(sdy::ShardyXLA().Run(&module).status());
  } else {
    ABSL_RETURN_IF_ERROR(
        ShardingPropagation(
            true, false, config.allow_spmd_sharding_propagation_to_output(),
            config.allow_spmd_sharding_propagation_to_parameters())
            .Run(&module)
            .status());
  }
  ABSL_RETURN_IF_ERROR(
      spmd::StatefulRngSpmdPartitioner(build.num_partitions(), 1)
          .Run(&module)
          .status());
  ABSL_RETURN_IF_ERROR(ControlDepRewriter().Run(&module).status());
  ABSL_RETURN_IF_ERROR(CallInliner().Run(&module).status());
  // All remaining CPU optimization and code generation still run normally.
  build.set_use_shardy_partitioner(false);
  auto* debug = build.mutable_debug_options();
  debug->add_xla_disable_hlo_passes("spmd-partitioner/sharding-propagation");
  debug->add_xla_disable_hlo_passes("spmd-partitioner/spmd-partitioning");
  // The caller now compiles local shapes, not the original global signature.
  options.argument_layouts.reset();
  build.set_result_layout(module.entry_computation_layout().result_shape());
  return absl::OkStatus();
}
}  // namespace xla::sim
