#include "src/bundle_timing.h"

#include <spawn.h>
#include <sys/wait.h>
#include <unistd.h>

#include <cerrno>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <utility>
#include <vector>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "google/protobuf/struct.pb.h"
#include "google/protobuf/util/json_util.h"

extern char** environ;

namespace xla::sim {
const absl::StatusOr<std::string>& BundleDumpDirectory() {
  static const auto directory = []() -> absl::StatusOr<std::string> {
    char path[] = "/tmp/pjrt-sim-bundles-XXXXXX";
    if (!mkdtemp(path))
      return absl::UnavailableError(
          absl::StrCat("Creating bundle directory: ", strerror(errno)));
    return std::string(path);
  }();
  return directory;
}

absl::StatusOr<BundleCompilation> EstimateFinalBundles(
    const std::vector<std::string>& files) {
  const char* profile = std::getenv("PJRT_SIM_BUNDLE_PROFILE");
  if (!profile || !*profile)
    return absl::InvalidArgumentError(
        "libtpu bundle timing requires PJRT_SIM_BUNDLE_PROFILE");
  const char* python = std::getenv("PJRT_SIM_BUNDLE_PYTHON");
  if (!python || !*python) python = "python3";
  if (files.empty()) return absl::InvalidArgumentError("No Final LLO bundles");
  const std::string manifest_path = files.front() + ".manifest.json";
  google::protobuf::Struct manifest;
  auto* paths = (*manifest.mutable_fields())["files"].mutable_list_value();
  for (const auto& file : files) paths->add_values()->set_string_value(file);
  std::string manifest_json;
  ABSL_RETURN_IF_ERROR(
      google::protobuf::util::MessageToJsonString(manifest, &manifest_json));
  std::ofstream output(manifest_path);
  output << manifest_json;
  output.close();
  if (!output) return absl::UnavailableError("Cannot write Final LLO manifest");
  const std::string report_path = manifest_path + ".timing.json";
  std::vector<std::string> command = {
      python,  "-m",        "bundle_timing", manifest_path, "--profile",
      profile, "--summary", "--output",      report_path};
  if (const char* scenario = std::getenv("PJRT_SIM_BUNDLE_SCENARIO");
      scenario && *scenario) {
    command.insert(command.end(), {"--scenario", scenario});
  }
  std::vector<char*> argv;
  for (auto& argument : command) argv.push_back(argument.data());
  argv.push_back(nullptr);
  pid_t child;
  // No shell, fork callbacks or Python embedding in the multi-threaded PJRT
  // host.
  const int error =
      posix_spawnp(&child, python, nullptr, nullptr, argv.data(), environ);
  if (error)
    return absl::UnavailableError(
        absl::StrCat("Starting bundle estimator: ", strerror(error)));
  int status;
  while (waitpid(child, &status, 0) < 0) {
    if (errno == EINTR) continue;
    return absl::UnavailableError(
        absl::StrCat("Waiting for bundle estimator: ", strerror(errno)));
  }
  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
    return absl::FailedPreconditionError(
        "Bundle estimator failed; check stderr and make bundle_timing "
        "importable via PYTHONPATH");
  std::ifstream file(report_path);
  if (!file)
    return absl::DataLossError("Bundle estimator did not write a report");
  BundleCompilation result;
  result.report_json.assign(std::istreambuf_iterator<char>(file), {});
  google::protobuf::Struct report;
  ABSL_RETURN_IF_ERROR(
      google::protobuf::util::JsonStringToMessage(result.report_json, &report));
  const auto& fields = report.fields();
  const auto stage = fields.find("bundle_stage");
  if (stage == fields.end() || stage->second.string_value() != "final_bundles")
    return absl::DataLossError("Expected Final LLO bundle timing report");
  const auto seconds = fields.find("modeled_seconds");
  const auto bundles = fields.find("scheduled_bundle_count");
  const auto gaps = fields.find("gaps");
  const auto state = fields.find("status");
  if (seconds == fields.end() || !seconds->second.has_number_value() ||
      bundles == fields.end() || !bundles->second.has_number_value() ||
      gaps == fields.end() || !gaps->second.has_list_value() ||
      state == fields.end())
    return absl::DataLossError("Incomplete bundle timing report");
  const double duration = seconds->second.number_value();
  if (!std::isfinite(duration) || duration < 0 || duration > 1e9 ||
      !std::isfinite(bundles->second.number_value()) ||
      bundles->second.number_value() < 1)
    return absl::DataLossError("Invalid bundle timing duration/count");
  result.timing.duration_ns = static_cast<int64_t>(std::ceil(duration * 1e9));
  result.timing.bundles = static_cast<int64_t>(bundles->second.number_value());
  result.timing.cost_gaps = gaps->second.list_value().values_size();
  const auto timeline = fields.find("activity_timeline");
  if (timeline == fields.end() || !timeline->second.has_list_value())
    return absl::DataLossError("Missing Final LLO activity timeline");
  std::vector<BundleActivity> activities;
  activities.reserve(timeline->second.list_value().values_size());
  for (const auto& value : timeline->second.list_value().values()) {
    if (!value.has_struct_value())
      return absl::DataLossError("Invalid Final LLO activity");
    const auto& activity = value.struct_value().fields();
    BundleActivity event;
    for (auto [key, target] : {std::pair{"name", &event.name},
                               {"track", &event.track},
                               {"detail", &event.detail},
                               {"cost_gap", &event.cost_gap}}) {
      const auto field = activity.find(key);
      if (field == activity.end() || !field->second.has_string_value())
        return absl::DataLossError("Invalid Final LLO activity label");
      *target = field->second.string_value();
    }
    for (auto [key, target] : {std::pair{"start_ns", &event.start_ns},
                               {"end_ns", &event.end_ns},
                               {"bytes", &event.bytes}}) {
      const auto field = activity.find(key);
      if (field == activity.end() || !field->second.has_number_value())
        return absl::DataLossError("Invalid Final LLO activity offset/size");
      const double number = field->second.number_value();
      if (!std::isfinite(number) || std::floor(number) != number ||
          number < (target == &event.bytes ? -1 : 0) || number > 1e18)
        return absl::DataLossError("Invalid Final LLO activity offset/size");
      *target = static_cast<int64_t>(number);
    }
    if (event.name.empty() || event.track.empty() ||
        event.start_ns > event.end_ns ||
        event.end_ns > result.timing.duration_ns)
      return absl::DataLossError(
          "Final LLO activity outside executable interval");
    activities.push_back(std::move(event));
  }
  result.timing.activities =
      std::make_shared<const std::vector<BundleActivity>>(
          std::move(activities));
  const auto settings = fields.find("profile");
  bool allow_partial = false;
  if (settings != fields.end() && settings->second.has_struct_value()) {
    const auto& config = settings->second.struct_value().fields();
    auto option = config.find("allow_partial");
    allow_partial = option != config.end() && option->second.has_bool_value() &&
                    option->second.bool_value();
  }
  if (state->second.string_value() != "modeled" &&
      state->second.string_value() != "partial")
    return absl::DataLossError("Invalid bundle timing status");
  if ((result.timing.cost_gaps || state->second.string_value() == "partial") &&
      !allow_partial)
    return absl::FailedPreconditionError(absl::StrCat(
        "Bundle timing has unresolved semantics. Inspect ", report_path,
        "; supply a scenario or explicitly set allow_partial=true in the "
        "profile. No HLO fallback."));
  return result;
}
}  // namespace xla::sim
