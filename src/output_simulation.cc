#include "src/output_simulation.h"

#include <algorithm>
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
        if (target != "tpu_custom_call" && target != "sim_pallas") {
          return absl::UnimplementedError(absl::StrCat(
              "TPU simulator has no adapter for custom call: ", target));
        }
        if (instruction->HasSideEffect()) {
          return absl::UnimplementedError(
              "TPU kernel side effects require an explicit adapter");
        }
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
