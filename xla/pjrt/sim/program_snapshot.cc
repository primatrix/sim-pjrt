// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
#include "xla/pjrt/sim/program_snapshot.h"

#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "google/protobuf/struct.pb.h"
#include "google/protobuf/util/json_util.h"

namespace xla::sim {
namespace {
const char* KindName(PlanNode::Kind kind) {
  switch (kind) {
    case PlanNode::Kind::kBarrier:
      return "barrier";
    case PlanNode::Kind::kCompute:
      return "compute";
    case PlanNode::Kind::kAllReduce:
      return "all-reduce";
    case PlanNode::Kind::kAllGather:
      return "all-gather";
    case PlanNode::Kind::kReduceScatter:
      return "reduce-scatter";
    case PlanNode::Kind::kTransfers:
      return "transfers";
  }
  return "barrier";
}
}  // namespace

absl::StatusOr<std::string> SerializeExecutionPlan(const ExecutionPlan& plan,
                                                   int64_t devices) {
  google::protobuf::Struct object;
  auto& fields = *object.mutable_fields();
  fields["schema_version"].set_number_value(1);
  fields["devices"].set_number_value(devices);
  fields["root"].set_number_value(plan.root);
  fields["cost_gaps"].set_number_value(plan.cost_gaps);
  auto* nodes = fields["nodes"].mutable_list_value();
  for (const PlanNode& node : plan.nodes) {
    auto& row = *nodes->add_values()->mutable_struct_value()->mutable_fields();
    row["name"].set_string_value(node.name);
    row["kind"].set_string_value(KindName(node.kind));
    row["hlo_id"].set_string_value(node.hlo_id < 0 ? ""
                                                   : absl::StrCat(node.hlo_id));
    row["opcode"].set_string_value(node.opcode);
    row["dtype"].set_string_value(node.dtype);
    row["inferred"].set_bool_value(node.inferred);
    row["framework_op"].set_string_value(node.framework_op);
    row["cost_gap"].set_string_value(node.cost_gap);
    row["cost_source"].set_string_value(node.cost_source);
    row["flops"].set_number_value(node.flops);
    row["transcendentals"].set_number_value(node.transcendentals);
    row["bytes"].set_number_value(node.bytes);
    row["logical_read_bytes"].set_number_value(node.read_bytes);
    row["logical_write_bytes"].set_number_value(node.write_bytes);
    auto* dependencies = row["dependencies"].mutable_list_value();
    for (int dependency : node.dependencies)
      dependencies->add_values()->set_number_value(dependency);
    auto* transfers = row["transfers"].mutable_list_value();
    for (const auto& [source, target] : node.transfers) {
      auto* pair = transfers->add_values()->mutable_list_value();
      pair->add_values()->set_number_value(source);
      pair->add_values()->set_number_value(target);
    }
  }
  std::string json;
  ABSL_RETURN_IF_ERROR(
      google::protobuf::util::MessageToJsonString(object, &json));
  return json;
}

absl::StatusOr<std::string> CaptureProgramSnapshot(const HloModule& module,
                                                   const ExecutionPlan& plan,
                                                   int64_t devices,
                                                   bool partitioned) {
  std::string hlo;
  google::protobuf::util::JsonPrintOptions options;
  options.preserve_proto_field_names = true;
  ABSL_RETURN_IF_ERROR(google::protobuf::util::MessageToJsonString(
      module.ToProto(), &hlo, options));
  ABSL_ASSIGN_OR_RETURN(std::string json,
                        SerializeExecutionPlan(plan, devices));
  return absl::StrCat("{\"schema_version\":2,\"shape_scope\":\"",
                      partitioned ? "per_partition" : "pre_partition",
                      "\",\"hlo\":", hlo, ",\"plan\":", json, "}");
}
}  // namespace xla::sim
