#include "src/hlo_model.h"

#include <algorithm>
#include <vector>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "xla/hlo/ir/hlo_computation.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/hlo/ir/hlo_opcode.h"
#include "xla/literal_util.h"
#include "src/hlo_utils.h"
#include "xla/primitive_util.h"
#include "xla/service/hlo_cost_analysis.h"
#include "xla/shape_util.h"

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

WorkEstimate Estimate(const HloComputation& computation,
                      const HloCostAnalysis& analysis) {
  WorkEstimate work;
  for (const HloInstruction* instruction : computation.instructions()) {
    if (instruction->opcode() == HloOpcode::kCall) {
      // A shared callee runs once per call site. Do not add both the callee's
      // work and the already aggregated call cost reported by HloCostAnalysis.
      WorkEstimate callee = Estimate(*instruction->to_apply(), analysis);
      work.dot_flops += callee.dot_flops;
      work.logical_bytes += callee.logical_bytes;
      work.unmodeled_ops += callee.unmodeled_ops;
      continue;
    }
    if (!instruction->called_computations().empty()) {
      // Dynamic branches/loops and higher-order operations need their own
      // model. Exclude their aggregate cost rather than invent multiplicities.
      ++work.unmodeled_ops;
      continue;
    }
    if (IsShardingAnnotation(*instruction)) continue;
    if (instruction->opcode() == HloOpcode::kCustomCall) {
      ++work.unmodeled_ops;
      continue;
    }
    work.logical_bytes +=
        std::max<int64_t>(0, analysis.bytes_accessed(*instruction));
    if (instruction->opcode() == HloOpcode::kDot) {
      work.dot_flops += std::max<int64_t>(0, analysis.flop_count(*instruction));
    }
  }
  return work;
}

}  // namespace

absl::StatusOr<WorkEstimate> PrepareForSimulation(HloModule& module) {
  HloCostAnalysis analysis([](const Shape& shape) {
    return ShapeUtil::ByteSizeOf(shape, sizeof(void*));
  });
  ABSL_RETURN_IF_ERROR(module.entry_computation()->Accept(&analysis));
  WorkEstimate estimate = Estimate(*module.entry_computation(), analysis);
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
      ++estimate.substituted_ops;
    }
  }
  return estimate;
}

}  // namespace xla::sim
