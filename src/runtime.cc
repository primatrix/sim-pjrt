#include "src/runtime.h"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <type_traits>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/status_macros.h"
#include "absl/strings/numbers.h"
#include "absl/strings/str_cat.h"
#include "google/protobuf/struct.pb.h"
#include "google/protobuf/util/json_util.h"
#include "tsl/platform/env.h"

namespace xla::sim {
namespace {
using Clock = std::chrono::steady_clock;
int64_t Now() {
  return std::chrono::duration_cast<std::chrono::nanoseconds>(
             Clock::now().time_since_epoch())
      .count();
}
int64_t Duration(double seconds) {
  // Bound pathological shapes/configurations before converting to integer ns.
  return static_cast<int64_t>(std::ceil(std::min(seconds, 86400.0) * 1e9));
}
}  // namespace

absl::StatusOr<RuntimeConfig> RuntimeConfig::FromProfile(
    absl::string_view json) {
  google::protobuf::Struct profile;
  ABSL_RETURN_IF_ERROR(
      google::protobuf::util::JsonStringToMessage(json, &profile));
  RuntimeConfig config;
  auto section = profile.fields().find("runtime");
  if (section == profile.fields().end()) return config;
  if (!section->second.has_struct_value())
    return absl::InvalidArgumentError("profile.runtime must be an object");
  for (const auto& [name, field] : section->second.struct_value().fields()) {
    auto read = [&](auto& value, double maximum,
                    bool zero = false) -> absl::Status {
      using T = std::decay_t<decltype(value)>;
      const double number = field.number_value();
      if (!field.has_number_value() || !std::isfinite(number) || number < 0 ||
          (!zero && number == 0) || number > maximum ||
          (std::is_integral_v<T> && std::floor(number) != number))
        return absl::InvalidArgumentError(
            absl::StrCat("Invalid profile.runtime.", name));
      value = static_cast<T>(number);
      return absl::OkStatus();
    };
    if (name == "launch_ns") {
      ABSL_RETURN_IF_ERROR(read(config.launch_ns, 1e9, true));
    } else if (name == "transfer_ns") {
      ABSL_RETURN_IF_ERROR(read(config.transfer_ns, 1e9, true));
    } else if (name == "link_ns") {
      ABSL_RETURN_IF_ERROR(read(config.link_ns, 1e9, true));
    } else if (name == "host_bytes_per_second") {
      ABSL_RETURN_IF_ERROR(read(config.host_bytes_per_second, 1e30));
    } else if (name == "link_bytes_per_second") {
      ABSL_RETURN_IF_ERROR(read(config.link_bytes_per_second, 1e30));
    } else if (name == "communication_scale") {
      ABSL_RETURN_IF_ERROR(read(config.communication_scale, 1e6));
    } else
      return absl::InvalidArgumentError(
          absl::StrCat("Unknown profile.runtime field: ", name));
  }
  return config;
}

absl::StatusOr<RuntimeConfig> RuntimeConfig::FromEnvironment() {
  // One timing configuration: both runtime and bundle estimator read this file.
  const char* path = std::getenv("PJRT_SIM_BUNDLE_PROFILE");
  if (!path || !*path)
    return absl::InvalidArgumentError("PJRT_SIM_BUNDLE_PROFILE is required");
  std::ifstream file(path);
  if (!file)
    return absl::InvalidArgumentError(
        absl::StrCat("Cannot read profile: ", path));
  std::string json(std::istreambuf_iterator<char>{file}, {});
  ABSL_ASSIGN_OR_RETURN(auto config, FromProfile(json));
  for (const char* old :
       {"PJRT_SIM_LAUNCH_NS", "PJRT_SIM_TRANSFER_NS", "PJRT_SIM_LINK_NS",
        "PJRT_SIM_HOST_BYTES_PER_SECOND", "PJRT_SIM_LINK_BYTES_PER_SECOND",
        "PJRT_SIM_COMMUNICATION_SCALE"}) {
    if (std::getenv(old))
      return absl::InvalidArgumentError(absl::StrCat(
          old,
          " was removed; use the runtime object in PJRT_SIM_BUNDLE_PROFILE"));
  }
  return config;
}

SimRuntime::SimRuntime(RuntimeConfig config)
    : config_(config),
      epoch_offset_(tsl::Env::Default()->NowNanos() - Now()),
      worker_([this] { Run(); }) {}

SimRuntime::~SimRuntime() {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    stopping_ = true;
  }
  changed_.notify_one();
  worker_.join();
}

void SimRuntime::Run() {
  std::unique_lock<std::mutex> lock(mutex_);
  while (!stopping_ || !timers_.empty()) {
    if (timers_.empty()) {
      changed_.wait(lock);
      continue;
    }
    const Timer timer = timers_.top();
    if (!stopping_ && timer.deadline > Now()) {
      changed_.wait_until(
          lock, Clock::time_point(std::chrono::nanoseconds(timer.deadline)));
      continue;
    }
    timers_.pop();
    const absl::Status status =
        stopping_ ? absl::CancelledError("Simulator client destroyed")
                  : absl::OkStatus();
    lock.unlock();
    // PJRT callbacks can reenter the runtime or wait for other events. Never
    // execute them under the scheduler lock or on the deadline worker.
    tsl::Env::Default()->SchedClosure(
        [promise = timer.promise, status]() { promise->Set(status); });
    lock.lock();
  }
}

Completion SimRuntime::CompleteAt(int64_t end) {
  auto [promise, future] = MakePromise();
  timers_.push(
      Timer{end, sequence_++, std::make_shared<Promise<>>(std::move(promise))});
  changed_.notify_one();
  return Completion{end, std::move(future)};
}

int64_t SimRuntime::Reserve(int64_t start, int64_t duration,
                            const std::vector<std::string>& resources) {
  if (!duration) return start;
  for (const std::string& resource : resources)
    start = std::max(start, resources_[resource]);
  for (const std::string& resource : resources)
    resources_[resource] = start + duration;
  return start;
}

std::vector<Completion> SimRuntime::ExecuteTimed(
    int64_t duration_ns, bool partial, const std::vector<int64_t>& devices,
    const std::vector<Completion>& inputs, const ProfileActivity& profile,
    const std::string& name, const std::vector<BundleActivity>& activities) {
  std::lock_guard<std::mutex> lock(mutex_);
  int64_t release = Now();
  std::vector<Future<>> predecessors;
  std::vector<std::string> resources;
  for (const auto& input : inputs) {
    release = std::max(release, input.end_ns);
    predecessors.push_back(input.future);
  }
  for (int64_t device : devices) {
    release = std::max(release, execution_tail_[device].end_ns);
    predecessors.push_back(execution_tail_[device].future);
    resources.push_back(absl::StrCat("compute:", device));
    resources.push_back(absl::StrCat("hbm:", device));
  }
  const int64_t start =
      Reserve(release + config_.launch_ns, duration_ns, resources);
  const int64_t end = start + duration_ns;
  std::vector<Completion> result;
  for (int64_t device : devices) {
    profile.Interval("device launch", Epoch(release),
                     Epoch(release + config_.launch_ns), device, "XLA TraceMe");
    profile.Interval(name, Epoch(start), Epoch(end), device, "XLA Modules",
                     partial ? "partial bundle cost coverage" : "");
    if (profile) {
      for (const auto& activity : activities) {
        const std::string gap = !activity.cost_gap.empty()
                                    ? activity.cost_gap
                                    : partial ? "partial bundle cost coverage" : "";
        profile.Interval(activity.name, Epoch(start + activity.start_ns),
                         Epoch(start + activity.end_ns), device, activity.track,
                         gap, activity.bytes, activity.detail,
                         activity.hlo_text, activity.tf_op, activity.source);
      }
    }
    Completion completion = CompleteAt(end);
    auto waits = predecessors;
    waits.push_back(completion.future);
    completion.future = JoinFutures(waits);
    execution_tail_[device] = completion;
    result.push_back(std::move(completion));
  }
  return result;
}

Completion SimRuntime::Transfer(int64_t source, int64_t destination,
                                int64_t bytes, const Completion& input,
                                const ProfileActivity& profile) {
  std::lock_guard<std::mutex> lock(mutex_);
  const bool host = source < 0 || destination < 0;
  const int64_t device = destination < 0 ? source : destination;
  const int64_t duration =
      Duration(config_.communication_scale *
               ((host ? config_.transfer_ns : config_.link_ns) / 1e9 +
                bytes / (host ? config_.host_bytes_per_second
                              : config_.link_bytes_per_second)));
  std::vector<std::string> resources = {
      absl::StrCat("link:", source, ":", destination)};
  if (source >= 0) resources.push_back(absl::StrCat("hbm:", source));
  if (destination >= 0) resources.push_back(absl::StrCat("hbm:", destination));
  const int64_t start =
      Reserve(std::max(Now(), input.end_ns), duration, resources);
  profile.Interval(source < 0        ? "H2D"
                   : destination < 0 ? "D2H"
                                     : "Device copy",
                   Epoch(start), Epoch(start + duration), device, "XLA TraceMe", {},
                   bytes);
  Completion completion = CompleteAt(start + duration);
  completion.future = JoinFutures({input.future, completion.future});
  return completion;
}

}  // namespace xla::sim
