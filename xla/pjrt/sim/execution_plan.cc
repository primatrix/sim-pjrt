// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "xla/pjrt/sim/execution_plan.h"

#include <algorithm>
#include <cmath>
#include <map>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/status/statusor.h"
#include "xla/hlo/ir/hlo_computation.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/pjrt/sim/hlo_utils.h"
#include "xla/pjrt/sim/pallas_cost.h"
#include "xla/shape_util.h"

namespace xla::sim {
namespace {

bool Local(const HloInstruction* instruction) {
  if (instruction->has_sharding() && instruction->sharding().IsManual())
    return true;
  if (instruction->opcode() == HloOpcode::kGetTupleElement)
    return Local(instruction->operand(0));
  if (instruction->opcode() != HloOpcode::kCustomCall) return false;
  return instruction->custom_call_target() == "xla.sdy.GlobalToLocalShape" ||
         instruction->custom_call_target() == "SPMDFullToShardShape";
}

absl::StatusOr<std::vector<int64_t>> Tiles(const HloInstruction& instruction,
                                           int64_t devices, bool local) {
  if (!instruction.shape().IsArray() || instruction.shape().is_dynamic())
    return absl::UnimplementedError("non-static array shape");
  std::vector<int64_t> tiles(instruction.shape().dimensions().size(), 1);
  if (local || devices == 1 || Local(&instruction) ||
      instruction.opcode() == HloOpcode::kConstant)
    return tiles;
  const HloSharding* sharding =
      instruction.has_sharding() ? &instruction.sharding() : nullptr;
  if (!sharding) {
    for (const HloInstruction* user : instruction.users()) {
      if (user->opcode() != HloOpcode::kCustomCall ||
          user->custom_call_target() != "Sharding" || !user->has_sharding())
        continue;
      if (sharding && *sharding != user->sharding())
        return absl::UnimplementedError("conflicting sharding annotations");
      sharding = &user->sharding();
    }
  }
  if (!sharding) return absl::UnimplementedError("unknown sharding");
  if (sharding->IsReplicated() || sharding->IsManual()) return tiles;
  if (!sharding->IsTiled() ||
      sharding->tile_assignment().num_dimensions() != tiles.size() ||
      sharding->tile_assignment().num_elements() != devices)
    return absl::UnimplementedError("unsupported sharding");
  int64_t ordinal = 0;
  for (int64_t device : sharding->tile_assignment().array()) {
    if (device != ordinal++)
      return absl::UnimplementedError("non-identity device assignment");
  }
  for (int d = 0; d < tiles.size(); ++d) {
    tiles[d] = sharding->tile_assignment().dim(d);
    if (instruction.shape().dimensions(d) % tiles[d])
      return absl::UnimplementedError("uneven sharding");
  }
  return tiles;
}

absl::StatusOr<double> Bytes(const HloInstruction& instruction, int64_t devices,
                             bool local) {
  ABSL_ASSIGN_OR_RETURN(std::vector<int64_t> tiles,
                        Tiles(instruction, devices, local));
  double bytes = ShapeUtil::ByteSizeOfElements(instruction.shape());
  for (int64_t tile : tiles) bytes /= tile;
  return bytes;
}

// A roofline approximation for explicitly supported memory operations. Higher
// order ops, opaque kernels and unfamiliar layouts remain visible coverage
// gaps.
bool MemoryOperation(const HloInstruction& instruction) {
  if (instruction.IsElementwise()) return true;
  switch (instruction.opcode()) {
    case HloOpcode::kBroadcast:
    case HloOpcode::kConcatenate:
    case HloOpcode::kCopy:
    case HloOpcode::kDynamicSlice:
    case HloOpcode::kDynamicUpdateSlice:
    case HloOpcode::kGather:
    case HloOpcode::kIota:
    case HloOpcode::kPad:
    case HloOpcode::kReverse:
    case HloOpcode::kSlice:
    case HloOpcode::kTranspose:
      return true;
    default:
      return false;
  }
}

absl::Status EstimateNode(const HloInstruction& instruction, int64_t devices,
                          bool local, PlanNode& node, bool& reduce) {
  const HloOpcode opcode = instruction.opcode();
  if (opcode == HloOpcode::kCustomCall &&
      instruction.custom_call_target() == "tpu_custom_call")
    return EstimatePallas(instruction, devices, local, node);
  if (opcode == HloOpcode::kParameter || opcode == HloOpcode::kConstant ||
      opcode == HloOpcode::kPartitionId || opcode == HloOpcode::kReplicaId ||
      opcode == HloOpcode::kTuple || opcode == HloOpcode::kGetTupleElement ||
      opcode == HloOpcode::kBitcast || opcode == HloOpcode::kReshape ||
      IsShardingAnnotation(instruction)) {
    if (IsShardingAnnotation(instruction) &&
        instruction.custom_call_target() == "Sharding" &&
        instruction.operand_count()) {
      ABSL_ASSIGN_OR_RETURN(auto source,
                            Tiles(*instruction.operand(0), devices, local));
      ABSL_ASSIGN_OR_RETURN(auto destination,
                            Tiles(instruction, devices, local));
      if (source != destination)
        return absl::UnimplementedError("unmodeled resharding");
    }
    return absl::OkStatus();
  }
  if (opcode == HloOpcode::kCollectivePermute) {
    if (!instruction.channel_id() || instruction.operand_count() != 1)
      return absl::UnimplementedError("unsupported collective-permute scope");
    std::vector<bool> sources(devices), targets(devices);
    for (const auto& [source, target] : instruction.source_target_pairs()) {
      if (source < 0 || target < 0 || source >= devices || target >= devices ||
          sources[source] || targets[target])
        return absl::UnimplementedError("unsupported collective-permute pairs");
      sources[source] = targets[target] = true;
      if (source != target) node.transfers.emplace_back(source, target);
    }
    ABSL_ASSIGN_OR_RETURN(node.bytes,
                          Bytes(*instruction.operand(0), devices, local));
    node.kind = PlanNode::Kind::kTransfers;
    return absl::OkStatus();
  }
  if (opcode == HloOpcode::kAllReduce || opcode == HloOpcode::kAllGather ||
      opcode == HloOpcode::kReduceScatter || opcode == HloOpcode::kAllToAll) {
    // With one replica, a channel identifies a partition collective. Only a
    // single full identity group is modeled; other groups remain coverage gaps.
    if (!instruction.channel_id().has_value() ||
        instruction.operand_count() != 1)
      return absl::UnimplementedError("unsupported collective scope");
    const auto& groups = instruction.replica_groups();
    if (groups.size() != 1 || groups[0].replica_ids_size() != devices)
      return absl::UnimplementedError("unsupported collective group");
    for (int d = 0; d < devices; ++d)
      if (groups[0].replica_ids(d) != d)
        return absl::UnimplementedError("non-identity collective group");
    ABSL_ASSIGN_OR_RETURN(node.bytes,
                          Bytes(*instruction.operand(0), devices, local));
    if (opcode == HloOpcode::kAllToAll) {
      node.kind = PlanNode::Kind::kTransfers;
      node.bytes = std::ceil(node.bytes / devices);
      for (int source = 0; source < devices; ++source)
        for (int target = 0; target < devices; ++target)
          if (source != target) node.transfers.emplace_back(source, target);
      return absl::OkStatus();
    }
    node.kind = opcode == HloOpcode::kAllReduce ? PlanNode::Kind::kAllReduce
                : opcode == HloOpcode::kAllGather
                    ? PlanNode::Kind::kAllGather
                    : PlanNode::Kind::kReduceScatter;
    return absl::OkStatus();
  }
  if (opcode == HloOpcode::kDot) {
    const auto& dims = instruction.dot_dimension_numbers();
    if (instruction.operand(0)->shape().dimensions().size() != 2 ||
        instruction.operand(1)->shape().dimensions().size() != 2 ||
        dims.lhs_contracting_dimensions_size() != 1 ||
        dims.rhs_contracting_dimensions_size() != 1 ||
        dims.lhs_contracting_dimensions(0) != 1 ||
        dims.rhs_contracting_dimensions(0) != 0 ||
        dims.lhs_batch_dimensions_size() || dims.rhs_batch_dimensions_size())
      return absl::UnimplementedError("unsupported dot dimensions");
    ABSL_ASSIGN_OR_RETURN(auto lhs,
                          Tiles(*instruction.operand(0), devices, local));
    ABSL_ASSIGN_OR_RETURN(auto rhs,
                          Tiles(*instruction.operand(1), devices, local));
    ABSL_ASSIGN_OR_RETURN(auto out, Tiles(instruction, devices, local));
    if (lhs[1] != rhs[0] || out != std::vector<int64_t>({lhs[0], rhs[1]}))
      return absl::UnimplementedError("dot requires unmodeled resharding");
    reduce = lhs[1] > 1;
    if (reduce && (lhs[1] != devices || out != std::vector<int64_t>({1, 1})))
      return absl::UnimplementedError("unsupported contracting group");
    node.flops = 2.0 *
                 (instruction.operand(0)->shape().dimensions(0) / lhs[0]) *
                 (instruction.operand(0)->shape().dimensions(1) / lhs[1]) *
                 (instruction.operand(1)->shape().dimensions(1) / rhs[1]);
  } else if (!MemoryOperation(instruction)) {
    return absl::UnimplementedError(opcode == HloOpcode::kCustomCall
                                        ? instruction.custom_call_target()
                                        : HloOpcodeString(opcode));
  }
  ABSL_ASSIGN_OR_RETURN(node.write_bytes, Bytes(instruction, devices, local));
  for (const HloInstruction* operand : instruction.operands()) {
    ABSL_ASSIGN_OR_RETURN(double bytes, Bytes(*operand, devices, local));
    node.read_bytes += bytes;
  }
  node.bytes = node.read_bytes + node.write_bytes;
  node.kind = PlanNode::Kind::kCompute;
  return absl::OkStatus();
}

class Builder {
 public:
  explicit Builder(int64_t devices) : devices_(devices) {}

  int Computation(const HloComputation& computation, bool local,
                  const std::vector<int>& arguments, int call_gate = -1) {
    std::map<const HloInstruction*, int> nodes;
    for (const HloInstruction* instruction :
         computation.MakeInstructionPostOrder()) {
      PlanNode node;
      node.name = instruction->name();
      node.hlo_id = instruction->unique_id();
      node.opcode = HloOpcodeString(instruction->opcode());
      node.dtype = PrimitiveType_Name(instruction->shape().element_type());
      node.framework_op = instruction->metadata().op_name();
      for (const HloInstruction* operand : instruction->operands())
        node.dependencies.push_back(nodes.at(operand));
      // Calls also gate independent callee work, including zero-argument calls.
      if (call_gate >= 0) node.dependencies.push_back(call_gate);
      for (const HloInstruction* predecessor :
           instruction->control_predecessors())
        node.dependencies.push_back(nodes.at(predecessor));
      if (instruction->opcode() == HloOpcode::kParameter && !arguments.empty())
        node.dependencies.push_back(
            arguments.at(instruction->parameter_number()));
      bool reduce = false;
      if (instruction->opcode() == HloOpcode::kCall) {
        bool child_local =
            local || (instruction->operand_count() &&
                      std::all_of(instruction->operands().begin(),
                                  instruction->operands().end(), Local));
        // Control predecessors gate the call as well as its return.
        std::vector<int> inputs = node.dependencies;
        PlanNode gate_node = node;
        // Scheduling-only node, not another HLO occurrence.
        gate_node.hlo_id = -1;
        const int gate = Add(std::move(gate_node));
        node.dependencies.push_back(
            Computation(*instruction->to_apply(), child_local, inputs, gate));
      } else {
        absl::Status status =
            EstimateNode(*instruction, devices_, local, node, reduce);
        if (!status.ok()) {
          node.cost_gap = std::string(status.message());
          node.bytes = node.flops = node.transcendentals = 0;
          node.read_bytes = node.write_bytes = 0;
          node.transfers.clear();
          node.cost_source.clear();
          node.kind = PlanNode::Kind::kBarrier;
          reduce = false;
          ++plan_.cost_gaps;
        }
      }
      int result = Add(std::move(node));
      if (reduce) {
        PlanNode collective;
        collective.name = "tensor-parallel all-reduce";
        collective.inferred = true;
        collective.framework_op = instruction->metadata().op_name();
        collective.kind = PlanNode::Kind::kAllReduce;
        collective.dependencies = {result};
        collective.bytes = *Bytes(*instruction, devices_, local);
        result = Add(std::move(collective));
      }
      nodes[instruction] = result;
    }
    // Include side-effect/control work even when it is not a data ancestor of
    // the root. Completion must not precede any submitted instruction.
    PlanNode done;
    done.name = "program complete";
    for (const auto& [instruction, index] : nodes)
      done.dependencies.push_back(index);
    return Add(std::move(done));
  }

  ExecutionPlan Build(const HloModule& module, bool partitioned) {
    plan_.root = Computation(*module.entry_computation(), partitioned, {});
    return std::move(plan_);
  }

 private:
  int Add(PlanNode node) {
    // Canonical dependency order makes snapshots stable across process reloads.
    std::sort(node.dependencies.begin(), node.dependencies.end());
    node.dependencies.erase(
        std::unique(node.dependencies.begin(), node.dependencies.end()),
        node.dependencies.end());
    if (node.cost_source == "pallas_cost_estimate") {
      plan_.kernel_flops += node.flops;
      plan_.kernel_transcendentals += node.transcendentals;
      plan_.kernel_bytes += node.bytes;
    }
    plan_.nodes.push_back(std::move(node));
    return plan_.nodes.size() - 1;
  }
  const int64_t devices_;
  ExecutionPlan plan_;
};

}  // namespace

ExecutionPlan BuildExecutionPlan(const HloModule& module, int64_t devices,
                                 bool partitioned) {
  return Builder(devices).Build(module, partitioned);
}

}  // namespace xla::sim
