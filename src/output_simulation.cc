#include "src/output_simulation.h"

#include <algorithm>
#include <string>
#include <vector>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "src/hlo_utils.h"
#include "xla/hlo/ir/hlo_computation.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/literal_util.h"
#include "xla/primitive_util.h"

namespace xla::sim {
namespace {

HloInstruction* Placeholder(HloComputation& computation, const Shape& shape,
                            HloInstruction* kernel = nullptr,
                            ShapeIndex index = {}) {
  // Numerical simulation preserves aliased storage contents. In particular,
  // paged attention returns its KV cache without allocating a replacement.
  if (kernel != nullptr) {
    for (const auto& [output, input] : kernel->output_operand_aliasing()) {
      if (output != index) continue;
      HloInstruction* value = kernel->mutable_operand(input.first);
      for (int64_t element : input.second) {
        value =
            computation.AddInstruction(HloInstruction::CreateGetTupleElement(
                value->shape().tuple_shapes(element), value, element));
      }
      return value;
    }
  }
  if (shape.IsTuple()) {
    std::vector<HloInstruction*> elements;
    for (int64_t i = 0; i < shape.tuple_shapes_size(); ++i) {
      ShapeIndex child = index;
      child.push_back(i);
      elements.push_back(
          Placeholder(computation, shape.tuple_shapes(i), kernel, child));
    }
    return computation.AddInstruction(HloInstruction::CreateTuple(elements));
  }
  HloInstruction* zero = computation.AddInstruction(
      HloInstruction::CreateConstant(LiteralUtil::Zero(shape.element_type())));
  return computation.AddInstruction(
      HloInstruction::CreateBroadcast(shape, zero, {}));
}

bool HasOnlyArrays(const Shape& shape) {
  if (shape.IsTuple()) {
    return std::all_of(shape.tuple_shapes().begin(), shape.tuple_shapes().end(),
                       HasOnlyArrays);
  }
  return shape.IsArray() && shape.is_static();
}

// SGL-JAX fused_ep_moe v1 uses side effects for device-local scratch and
// cross-device DMA/barriers. Its public result is a fresh floating array;
// there is no host I/O or persistent state update. Recognize only its
// unquantized, no-shared-expert ABI (with optional all-reduce metadata).
bool IsFusedMoeCollective(const HloInstruction& instruction) {
  const auto& name = instruction.metadata().op_name();
  const auto position = name.find("fused-moe-k_");
  if (instruction.custom_call_target() != "tpu_custom_call" ||
      position == std::string::npos || (position && name[position - 1] != '/') ||
      !instruction.output_operand_aliasing().empty() ||
      !instruction.shape().IsArray() || instruction.shape().rank() != 2 ||
      !instruction.shape().is_static() ||
      !primitive_util::IsFloatingPointType(instruction.shape().element_type()) ||
      (instruction.operand_count() != 9 && instruction.operand_count() != 12)) {
    return false;
  }
  const auto dtype = instruction.shape().element_type();
  const int ranks[] = {3, 3, 3, 3, 2, 2, 4, 4, 4, 3, 3, 4};
  for (int64_t i = 0; i < instruction.operand_count(); ++i) {
    const Shape& shape = instruction.operand(i)->shape();
    const auto expected = i == 5 || i >= 9 ? S32 : (i == 4 ? F32 : dtype);
    if (!shape.IsArray() || !shape.is_static() ||
        shape.rank() != ranks[i] || shape.element_type() != expected) return false;
  }
  return true;
}

}  // namespace

absl::StatusOr<int64_t> SubstituteSimulationOutputs(HloModule& module) {
  int64_t substituted_ops = 0;
  for (HloComputation* computation : module.MakeComputationPostOrder()) {
    for (HloInstruction* instruction :
         computation->MakeInstructionPostOrder()) {
      const HloOpcode opcode = instruction->opcode();
      bool substitute =
          opcode == HloOpcode::kDot && primitive_util::IsFloatingPointType(
                                           instruction->shape().element_type());
      if (opcode == HloOpcode::kCustomCall) {
        const auto& target = instruction->custom_call_target();
        // Sharding annotations have no executable numerical semantics.
        if (IsShardingAnnotation(*instruction)) continue;
        const bool allocation = target == "AllocateBuffer";
        if (allocation &&
            (instruction->operand_count() != 0 ||
             !instruction->shape().IsArray() ||
             !instruction->output_operand_aliasing().empty())) {
          return absl::UnimplementedError(
              "AllocateBuffer requires an unaliased array with no operands");
        }
        if (target != "tpu_custom_call" && target != "sim_pallas" &&
            !allocation) {
          return absl::UnimplementedError(absl::StrCat(
              "TPU simulator has no adapter for custom call: ", target));
        }
        if (instruction->HasSideEffect() && !IsFusedMoeCollective(*instruction)) {
          return absl::UnimplementedError(
              "TPU kernel side effects require an explicit adapter");
        }
        // Uninitialized scratch storage may contain any value. Zero-filled
        // virtual storage gives it deterministic contents without a TPU call.
        substitute = true;
      }
      if (!substitute) continue;
      if (!HasOnlyArrays(instruction->shape())) {
        return absl::UnimplementedError(
            "Simulation placeholders require static array outputs");
      }
      HloInstruction* replacement =
          Placeholder(*computation, instruction->shape(),
                      opcode == HloOpcode::kCustomCall ? instruction : nullptr);
      // An alias may reuse an existing parameter: keep its metadata intact.
      if (opcode == HloOpcode::kDot) {
        replacement->set_metadata(instruction->metadata());
      }
      ABSL_RETURN_IF_ERROR(
          computation->ReplaceInstruction(instruction, replacement));
      ++substituted_ops;
    }
  }
  return substituted_ops;
}

}  // namespace xla::sim
