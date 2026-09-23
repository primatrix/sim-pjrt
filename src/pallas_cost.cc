// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "src/pallas_cost.h"

#include <algorithm>
#include <cmath>

#include "absl/status/status_macros.h"
#include "absl/status/statusor.h"
#include "absl/strings/numbers.h"
#include "absl/strings/str_cat.h"
#include "google/protobuf/struct.pb.h"
#include "google/protobuf/util/json_util.h"
#include "xla/hlo/ir/hlo_opcode.h"

namespace xla::sim {
namespace {

absl::StatusOr<double> Count(const google::protobuf::Struct& object,
                             const char* name, bool optional = false) {
  const auto it = object.fields().find(name);
  if (it == object.fields().end()) {
    if (optional) return 0;
    return absl::InvalidArgumentError(absl::StrCat("missing Pallas ", name));
  }
  const google::protobuf::Value& value = it->second;
  double count = -1;
  if (value.kind_case() == google::protobuf::Value::kNumberValue) {
    count = value.number_value();
  } else if (value.kind_case() == google::protobuf::Value::kStringValue) {
    // Protobuf JSON encodes int64 fields as strings; JAX also emits numbers.
    if (!absl::SimpleAtod(value.string_value(), &count)) count = -1;
  }
  if (!std::isfinite(count) || count < 0 || count >= 0x1p63 ||
      std::floor(count) != count)
    return absl::InvalidArgumentError(absl::StrCat("invalid Pallas ", name));
  return count;
}

}  // namespace

absl::Status EstimatePallas(const HloInstruction& instruction, int64_t devices,
                            bool local, PlanNode& node) {
  const bool replicated =
      instruction.has_sharding() && instruction.sharding().IsReplicated() &&
      std::all_of(instruction.operands().begin(), instruction.operands().end(),
                  [](const HloInstruction* operand) {
                    return operand->opcode() == HloOpcode::kConstant ||
                           (operand->has_sharding() &&
                            operand->sharding().IsReplicated());
                  });
  if (!(local || devices == 1 ||
        (instruction.has_sharding() && instruction.sharding().IsManual()) ||
        replicated))
    return absl::UnimplementedError(
        "Pallas cost requires local or replicated scope");
  if (instruction.HasSideEffect())
    return absl::UnimplementedError("Pallas side effects");
  google::protobuf::Struct config;
  if (!google::protobuf::util::JsonStringToMessage(
           instruction.raw_backend_config_string(), &config)
           .ok())
    return absl::InvalidArgumentError("invalid Pallas backend config JSON");
  const auto call = config.fields().find("custom_call_config");
  if (call == config.fields().end() ||
      call->second.kind_case() != google::protobuf::Value::kStructValue)
    return absl::UnimplementedError("missing Pallas custom_call_config");
  const auto& fields = call->second.struct_value().fields();
  const auto communication = fields.find("has_communication");
  if (communication != fields.end() &&
      (communication->second.kind_case() !=
           google::protobuf::Value::kBoolValue ||
       communication->second.bool_value()))
    return absl::UnimplementedError("Pallas internal communication");
  const auto cost = fields.find("cost_estimate");
  if (cost == fields.end() ||
      cost->second.kind_case() != google::protobuf::Value::kStructValue)
    return absl::UnimplementedError("missing Pallas cost_estimate");
  const auto& estimate = cost->second.struct_value();
  ABSL_ASSIGN_OR_RETURN(double remote,
                        Count(estimate, "remote_bytes_transferred", true));
  if (remote != 0)
    return absl::UnimplementedError("Pallas internal communication");
  ABSL_ASSIGN_OR_RETURN(node.flops, Count(estimate, "flops"));
  ABSL_ASSIGN_OR_RETURN(node.transcendentals,
                        Count(estimate, "transcendentals"));
  ABSL_ASSIGN_OR_RETURN(node.bytes, Count(estimate, "bytes_accessed"));
  node.kind = PlanNode::Kind::kCompute;
  node.cost_source = "pallas_cost_estimate";
  return absl::OkStatus();
}

}  // namespace xla::sim
