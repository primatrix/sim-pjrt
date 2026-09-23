// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
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
