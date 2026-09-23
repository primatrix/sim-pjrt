#ifndef XLA_PJRT_SIM_HLO_UTILS_H_
#define XLA_PJRT_SIM_HLO_UTILS_H_

#include <string>

#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/hlo/ir/hlo_opcode.h"

namespace xla::sim {

inline bool IsShardingAnnotation(const HloInstruction& instruction) {
  if (instruction.opcode() != HloOpcode::kCustomCall) return false;
  const std::string& target = instruction.custom_call_target();
  return target == "Sharding" || target == "SPMDFullToShardShape" ||
         target == "SPMDShardToFullShape" ||
         target == "xla.sdy.FuncResultSharding" ||
         target == "xla.sdy.GlobalToLocalShape" ||
         target == "xla.sdy.LocalToGlobalShape";
}

}  // namespace xla::sim
#endif  // XLA_PJRT_SIM_HLO_UTILS_H_
