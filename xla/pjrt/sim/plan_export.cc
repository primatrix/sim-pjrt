// Copyright 2026 The OpenXLA Authors. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy at https://www.apache.org/licenses/LICENSE-2.0
// Reads a snapshot on stdin and emits its replanned snapshot on stdout.
#include <iostream>
#include <iterator>
#include <memory>
#include <string>

#include "absl/status/status_macros.h"
#include "absl/status/statusor.h"
#include "absl/strings/numbers.h"
#include "google/protobuf/struct.pb.h"
#include "google/protobuf/util/json_util.h"
#include "xla/hlo/ir/hlo_module.h"
#include "xla/hlo/parser/hlo_parser.h"
#include "xla/pjrt/sim/execution_plan.h"
#include "xla/pjrt/sim/program_snapshot.h"

namespace xla::sim {
namespace {
absl::StatusOr<std::string> Export(const std::string& input, int64_t devices,
                                   bool hlo_text) {
  std::unique_ptr<HloModule> module;
  bool partitioned = false;
  if (hlo_text) {
    ABSL_ASSIGN_OR_RETURN(module, ParseAndReturnUnverifiedModule(input));
  } else {
    google::protobuf::Struct snapshot;
    ABSL_RETURN_IF_ERROR(
        google::protobuf::util::JsonStringToMessage(input, &snapshot));
    const auto& fields = snapshot.fields();
    const auto scope = fields.find("shape_scope");
    partitioned = scope != fields.end() &&
                  scope->second.string_value() == "per_partition";
    const auto hlo = fields.find("hlo");
    if (hlo == fields.end()) return absl::InvalidArgumentError("missing HLO");
    std::string json;
    ABSL_RETURN_IF_ERROR(
        google::protobuf::util::MessageToJsonString(hlo->second, &json));
    HloModuleProto proto;
    ABSL_RETURN_IF_ERROR(
        google::protobuf::util::JsonStringToMessage(json, &proto));
    ABSL_ASSIGN_OR_RETURN(HloModuleConfig config,
                          HloModule::CreateModuleConfigFromProto(proto, {}));
    ABSL_ASSIGN_OR_RETURN(
        module, HloModule::CreateFromProto(proto, config, nullptr,
                                           /*preserve_instruction_ids=*/true));
  }
  return CaptureProgramSnapshot(
      *module, BuildExecutionPlan(*module, devices, partitioned), devices,
      partitioned);
}
}  // namespace
}  // namespace xla::sim

int main(int argc, char** argv) {
  int64_t devices;
  if ((argc != 2 && argc != 3) || !absl::SimpleAtoi(argv[1], &devices) ||
      devices < 1 || (argc == 3 && std::string(argv[2]) != "--hlo-text")) {
    std::cerr << "Usage: plan_export DEVICES [--hlo-text] < snapshot.json\n";
    return 1;
  }
  const std::string input{std::istreambuf_iterator<char>(std::cin),
                          std::istreambuf_iterator<char>()};
  auto result = xla::sim::Export(input, devices, argc == 3);
  if (!result.ok()) {
    std::cerr << result.status() << '\n';
    return 1;
  }
  std::cout << *result << '\n';
  return 0;
}
