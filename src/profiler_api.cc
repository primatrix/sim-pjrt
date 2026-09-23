// This plugin owns its opaque C profiler handles. XSpace bytes stay alive
// until the next collection/start or until their owning handle is destroyed.
#include <cstring>
#include <memory>
#include <string>

#include "absl/status/status.h"
#include "xla/backends/profiler/plugin/profiler_error.h"
#include "src/profiler.h"
#include "tsl/profiler/protobuf/profiler_options.pb.h"

struct PLUGIN_Profiler {
  std::shared_ptr<xla::sim::ProfileSession> session;
  std::string bytes;
  bool running = false;
  bool collected = false;
};

struct PLUGIN_Profiler_ConsumeResult {
  std::string bytes;
};

namespace xla::sim {
namespace {
PLUGIN_Profiler_Error* Create(PLUGIN_Profiler_Create_Args* args) {
  tensorflow::ProfileOptions options;
  if (!options.ParseFromArray(args->options, args->options_size)) {
    return new PLUGIN_Profiler_Error{
        absl::InvalidArgumentError("Invalid profile options")};
  }
  args->profiler = new PLUGIN_Profiler;
  return nullptr;
}

PLUGIN_Profiler_Error* Destroy(PLUGIN_Profiler_Destroy_Args* args) {
  if (args->profiler) StopProfile(args->profiler->session);
  delete args->profiler;
  return nullptr;
}

PLUGIN_Profiler_Error* Start(PLUGIN_Profiler_Start_Args* args) {
  PLUGIN_PROFILER_ASSIGN_OR_RETURN(auto session, StartProfile());
  args->profiler->session = std::move(session);
  args->profiler->bytes.clear();
  args->profiler->running = true;
  args->profiler->collected = false;
  return nullptr;
}

PLUGIN_Profiler_Error* Stop(PLUGIN_Profiler_Stop_Args* args) {
  StopProfile(args->profiler->session);
  args->profiler->running = false;
  return nullptr;
}

absl::Status Collect(PLUGIN_Profiler* profiler) {
  if (profiler->running)
    return absl::FailedPreconditionError("Stop profiling before collecting");
  if (!profiler->collected) {
    profiler->bytes =
        profiler->session ? profiler->session->Serialize() : std::string();
    profiler->collected = true;
  }
  return absl::OkStatus();
}

PLUGIN_Profiler_Error* CollectData(PLUGIN_Profiler_CollectData_Args* args) {
  PLUGIN_PROFILER_RETURN_IF_ERROR(Collect(args->profiler));
  const std::string& bytes = args->profiler->bytes;
  if (args->buffer) {
    std::memcpy(args->buffer, bytes.data(), bytes.size());
  } else {
    // Current JAX consumes this owned pointer directly. Also support the
    // caller-allocated second call described by the public C API.
    args->buffer = reinterpret_cast<uint8_t*>(args->profiler->bytes.data());
  }
  args->buffer_size_in_bytes = bytes.size();
  return nullptr;
}

PLUGIN_Profiler_Error* Consume(PLUGIN_Profiler_Consume_Args* args) {
  PLUGIN_PROFILER_RETURN_IF_ERROR(Collect(args->profiler));
  args->result = new PLUGIN_Profiler_ConsumeResult{args->profiler->bytes};
  return nullptr;
}

void DestroyResult(PLUGIN_Profiler_ConsumeResult_Destroy_Args* args) {
  delete args->consume_result;
}

PLUGIN_Profiler_Error* Serialize(PLUGIN_Profiler_Serialize_Args* args) {
  args->serialized_bytes =
      reinterpret_cast<const uint8_t*>(args->consume_result->bytes.data());
  args->serialized_size = args->consume_result->bytes.size();
  return nullptr;
}
}  // namespace

PJRT_Profiler_Extension* ProfilerExtension() {
  static PLUGIN_Profiler_Api api = [] {
    PLUGIN_Profiler_Api result = {};
    result.struct_size = PLUGIN_Profiler_Api_STRUCT_SIZE;
    result.error_destroy = profiler::PLUGIN_Profiler_Error_Destroy;
    result.error_message = profiler::PLUGIN_Profiler_Error_Message;
    result.error_get_code = profiler::PLUGIN_Profiler_Error_GetCode;
    result.create = Create;
    result.destroy = Destroy;
    result.start = Start;
    result.stop = Stop;
    result.collect_data = CollectData;
    result.consume = Consume;
    result.consume_result_destroy = DestroyResult;
    result.serialize = Serialize;
    return result;
  }();
  static PJRT_Profiler_Extension extension = {
      {PJRT_Profiler_Extension_STRUCT_SIZE, PJRT_Extension_Type_Profiler,
       nullptr},
      &api,
      0};
  return &extension;
}
}  // namespace xla::sim
