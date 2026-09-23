#include "src/instrumentation.h"

#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <vector>

#include "absl/log/log.h"
#include "src/profiler.h"
#include "src/virtual_storage.h"
#include "tsl/platform/env.h"
#include "xla/pjrt/c/pjrt_c_api_cpu_internal.h"
#include "xla/pjrt/c/pjrt_c_api_helpers.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"

namespace xla::sim {
namespace {

struct Registry {
  std::mutex mutex;
  std::unordered_map<PJRT_Buffer*, uint64_t> buffers;
  std::unordered_map<PJRT_Buffer*, Completion> completions;
  std::unordered_map<PJRT_Client*, std::shared_ptr<SimRuntime>> runtimes;
  uint64_t next_buffer_id = 1;
  std::unordered_map<PJRT_LoadedExecutable*, ExecutableWork> work;
  std::ofstream trace;
  uint64_t sequence = 0;
  uint64_t next_program_id = 1;

  Registry() {
    if (const char* prefix = std::getenv("PJRT_SIM_TRACE")) {
      trace.open(std::string(prefix) + "." +
                     std::to_string(tsl::Env::Default()->GetProcessId()) +
                     ".jsonl",
                 std::ios::app);
      if (!trace) LOG(ERROR) << "Cannot open PJRT_SIM_TRACE output";
    }
  }
};

Registry& State() {
  static Registry registry;
  return registry;
}

uint64_t TrackLocked(PJRT_Buffer* buffer) {
  auto [it, inserted] = State().buffers.emplace(buffer, State().next_buffer_id);
  if (inserted) ++State().next_buffer_id;
  return it->second;
}

uint64_t Track(PJRT_Buffer* buffer) {
  std::lock_guard<std::mutex> lock(State().mutex);
  return TrackLocked(buffer);
}

std::shared_ptr<SimRuntime> Runtime(PJRT_Client* client) {
  std::lock_guard<std::mutex> lock(State().mutex);
  return State().runtimes.at(client);
}

Completion Producer(PJRT_Buffer* buffer) {
  std::lock_guard<std::mutex> lock(State().mutex);
  auto it = State().completions.find(buffer);
  return it == State().completions.end() ? Completion{} : it->second;
}

void SetProducer(PJRT_Buffer* buffer, Completion completion) {
  std::lock_guard<std::mutex> lock(State().mutex);
  State().completions[buffer] = std::move(completion);
}

Future<> BufferReady(PJRT_Buffer* buffer) {
  return JoinFutures(
      {Producer(buffer).future, buffer->buffer->GetReadyFuture()});
}

void TransferBuffer(PJRT_Buffer* buffer, int64_t source,
                    const Completion& input, const ProfileActivity& profile) {
  auto size = buffer->buffer->GetOnDeviceSizeInBytes();
  const int64_t device = buffer->buffer->device()->id();
  const auto runtime = Runtime(buffer->client);
  Completion completion =
      runtime->Transfer(source, device, size.ok() ? *size : 0, input, profile);
  // Store the modeled future; callers join CPU readiness only when data is
  // observed. Functional execution can run ahead without changing the model.
  SetProducer(buffer, std::move(completion));
}

void AppendId(std::string& ids, uint64_t id) {
  if (!ids.empty()) ids += ',';
  ids += std::to_string(id);
}

void ProfileBuffer(const ProfileActivity& activity, PJRT_Buffer* buffer,
                   const char* ready_name = nullptr) {
  if (!activity) return;
  const uint64_t id = Track(buffer);
  auto bytes = buffer->buffer->GetOnDeviceSizeInBytes();
  const int64_t size = bytes.ok() ? *bytes : -1;
  const int64_t device = buffer->buffer->device()->id();
  activity.SetBuffer(id, size, device);
  if (ready_name) {
    activity.Ready(BufferReady(buffer), ready_name, device, id, size);
  }
}

PJRT_Error* FromHost(PJRT_Client_BufferFromHostBuffer_Args* args) {
  ProfileCall profile("PJRT H2D submit");
  PJRT_Error* error = VirtualFromHost(args, MaxMaterializedBytes(args->client));
  if (!error) {
    Track(args->buffer);
    TransferBuffer(args->buffer, -1, {}, profile.activity());
    ProfileBuffer(profile.activity(), args->buffer, "H2D submit-to-ready");
    if (profile.activity())
      profile.activity().SetLinks({}, std::to_string(Track(args->buffer)));
  }
  if (error)
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
  return error;
}

PJRT_Error* Copy(PJRT_Buffer_CopyToMemory_Args* args) {
  ProfileCall profile("PJRT copy submit");
  PJRT_Error* error = pjrt::PJRT_Buffer_CopyToMemory(args);
  if (!error) {
    Track(args->dst_buffer);
    TransferBuffer(args->dst_buffer, args->buffer->buffer->device()->id(),
                   Producer(args->buffer), profile.activity());
    ProfileBuffer(profile.activity(), args->dst_buffer, "Copy submit-to-ready");
    if (profile.activity())
      profile.activity().SetLinks(std::to_string(Track(args->buffer)),
                                  std::to_string(Track(args->dst_buffer)));
  }
  if (error)
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
  return error;
}

PJRT_Error* Bitcast(PJRT_Buffer_Bitcast_Args* args) {
  ProfileCall profile("PJRT bitcast");
  PJRT_Error* error =
      pjrt::cpu_plugin::GetCpuPjrtApi()->PJRT_Buffer_Bitcast(args);
  if (!error) {
    Track(args->out_buffer);
    SetProducer(args->out_buffer, Producer(args->buffer));
    ProfileBuffer(profile.activity(), args->out_buffer);
    if (profile.activity())
      profile.activity().SetLinks(std::to_string(Track(args->buffer)),
                                  std::to_string(Track(args->out_buffer)));
  }
  if (error)
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
  return error;
}

PJRT_Error* CopyToDevice(PJRT_Buffer_CopyToDevice_Args* args) {
  ProfileCall profile("PJRT copy submit");
  PJRT_Error* error = pjrt::PJRT_Buffer_CopyToDevice(args);
  if (!error) {
    TransferBuffer(args->dst_buffer, args->buffer->buffer->device()->id(),
                   Producer(args->buffer), profile.activity());
    ProfileBuffer(profile.activity(), args->dst_buffer, "Copy submit-to-ready");
    profile.activity().SetLinks(std::to_string(Track(args->buffer)),
                                std::to_string(Track(args->dst_buffer)));
  }
  return error;
}

PJRT_Error* UnsafePointer(PJRT_Buffer_UnsafePointer_Args* args) {
  PJRT_RETURN_IF_ERROR(CheckMaterialized(args->buffer->buffer.get()));
  PJRT_RETURN_IF_ERROR(BufferReady(args->buffer).Await());
  return pjrt::PJRT_Buffer_UnsafePointer(args);
}

PJRT_Error* OpaquePointer(
    PJRT_Buffer_OpaqueDeviceMemoryDataPointer_Args* args) {
  PJRT_RETURN_IF_ERROR(CheckMaterialized(args->buffer->buffer.get()));
  PJRT_RETURN_IF_ERROR(BufferReady(args->buffer).Await());
  return pjrt::PJRT_Buffer_OpaqueDeviceMemoryDataPointer(args);
}

PJRT_Error* DestroyClient(PJRT_Client_Destroy_Args* args) {
  std::shared_ptr<SimRuntime> runtime;
  {
    std::lock_guard<std::mutex> lock(State().mutex);
    auto it = State().runtimes.find(args->client);
    if (it != State().runtimes.end()) {
      runtime = std::move(it->second);
      State().runtimes.erase(it);
    }
  }
  runtime.reset();  // Cancels timers outside the registry lock.
  return pjrt::PJRT_Client_Destroy(args);
}

PJRT_Error* ToHost(PJRT_Buffer_ToHostBuffer_Args* args) {
  ProfileCall profile(args->dst ? "PJRT D2H submit" : "PJRT D2H size query");
  ProfileBuffer(profile.activity(), args->src);
  PJRT_Error* error = pjrt::PJRT_Buffer_ToHostBuffer(args);
  if (!error && args->dst && args->event) {
    const int64_t device = args->src->buffer->device()->id();
    const auto runtime = Runtime(args->src->client);
    Completion copy = runtime->Transfer(
        device, -1, args->dst_size, Producer(args->src), profile.activity());
    args->event->future = JoinFutures({copy.future, args->event->future});
    profile.activity().Ready(args->event->future, "D2H submit-to-ready",
                             args->src->buffer->device()->id(),
                             Track(args->src), args->dst_size);
  }
  if (error)
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
  return error;
}

PJRT_Error* RawToHost(PJRT_Buffer_CopyRawToHost_Args* args) {
  ProfileCall profile("PJRT raw D2H submit");
  ProfileBuffer(profile.activity(), args->buffer);
  PJRT_Error* error = pjrt::PJRT_Buffer_CopyRawToHost(args);
  if (!error && args->event) {
    const int64_t device = args->buffer->buffer->device()->id();
    const auto runtime = Runtime(args->buffer->client);
    Completion copy =
        runtime->Transfer(device, -1, args->transfer_size,
                          Producer(args->buffer), profile.activity());
    args->event->future = JoinFutures({copy.future, args->event->future});
    profile.activity().SetBuffer(Track(args->buffer), args->transfer_size,
                                 args->buffer->buffer->device()->id());
    profile.activity().Ready(args->event->future, "Raw D2H submit-to-ready",
                             args->buffer->buffer->device()->id(),
                             Track(args->buffer), args->transfer_size);
  }
  if (error)
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
  return error;
}

PJRT_Error* ExternalReference(
    PJRT_Buffer_IncreaseExternalReferenceCount_Args* args) {
  // CPU-backed buffers can be read through an external reference. Such access
  // is not a TPU D2H transfer and must be named separately in the profile.
  PJRT_RETURN_IF_ERROR(CheckMaterialized(args->buffer->buffer.get()));
  PJRT_RETURN_IF_ERROR(BufferReady(args->buffer).Await());
  return pjrt::PJRT_Buffer_IncreaseExternalReferenceCount(args);
}

PJRT_Error* ReadyEvent(PJRT_Buffer_ReadyEvent_Args* args) {
  PJRT_Error* error = pjrt::PJRT_Buffer_ReadyEvent(args);
  if (!error) args->event->future = BufferReady(args->buffer);
  return error;
}

PJRT_Error* DestroyBuffer(PJRT_Buffer_Destroy_Args* args) {
  {
    std::lock_guard<std::mutex> lock(State().mutex);
    State().buffers.erase(args->buffer);
    State().completions.erase(args->buffer);
  }
  return pjrt::PJRT_Buffer_Destroy(args);
}

PJRT_Error* MemoryStats(PJRT_Device_MemoryStats_Args* args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Device_MemoryStats_Args", PJRT_Device_MemoryStats_Args_STRUCT_SIZE,
      args->struct_size));
  args->bytes_in_use = 0;
  args->bytes_limit = int64_t{96} << 30;
  args->bytes_limit_is_set = true;
  std::lock_guard<std::mutex> lock(State().mutex);
  for (const auto& [buffer, id] : State().buffers) {
    if (buffer->buffer->device() == args->device->device &&
        !buffer->buffer->IsDeleted()) {
      PJRT_ASSIGN_OR_RETURN(size_t bytes,
                            buffer->buffer->GetOnDeviceSizeInBytes());
      args->bytes_in_use += bytes;
    }
  }
  // These are logical live-buffer bytes, not the CPU allocator's physical peak.
  args->peak_bytes_in_use_is_set = false;
  args->num_allocs_is_set = false;
  args->largest_alloc_size_is_set = false;
  args->bytes_reserved_is_set = false;
  args->peak_bytes_reserved_is_set = false;
  args->bytes_reservable_limit_is_set = false;
  args->largest_free_block_bytes_is_set = false;
  args->pool_bytes_is_set = false;
  args->peak_pool_bytes_is_set = false;
  args->peak_allocated_bytes_is_set = false;
  return nullptr;
}

PJRT_Error* Execute(PJRT_LoadedExecutable_Execute_Args* args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_LoadedExecutable_Execute_Args",
      PJRT_LoadedExecutable_Execute_Args_STRUCT_SIZE, args->struct_size));
  ProfileCall profile("PJRT Execute submit", args->executable->get()->name());
  ExecutableWork work;
  {
    std::lock_guard<std::mutex> lock(State().mutex);
    work = State().work.at(args->executable);
  }
  if (work.num_replicas != 1)
    return pjrt::StatusToPjRtError(absl::UnimplementedError(
        "Online timing currently requires one replica with SPMD partitions"));
  std::vector<Completion> dependencies;
  for (size_t d = 0; d < args->num_devices; ++d)
    for (size_t a = 0; a < args->num_args; ++a)
      dependencies.push_back(Producer(args->argument_lists[d][a]));
  std::string inputs;
  if (profile.activity()) {
    for (size_t device = 0; device < args->num_devices; ++device) {
      for (size_t arg = 0; arg < args->num_args; ++arg) {
        AppendId(inputs, Track(args->argument_lists[device][arg]));
      }
    }
  }
  PJRT_ASSIGN_OR_RETURN(auto types,
                        args->executable->get()->GetOutputElementTypes());
  if (types.size() != 1) {
    return pjrt::StatusToPjRtError(
        absl::UnimplementedError("Expected a single SPMD output signature"));
  }
  // Request actual runtime completion futures even if the caller did not ask
  // for C events. Never wait here: the overlap scheduler depends on async
  // dispatch.
  PJRT_LoadedExecutable_Execute_Args execute_args = *args;
  std::vector<PJRT_Event*> owned_events;
  if (!args->device_complete_events) {
    owned_events.resize(args->num_devices, nullptr);
    execute_args.device_complete_events = owned_events.data();
  }
  PJRT_Error* error = pjrt::PJRT_LoadedExecutable_Execute(&execute_args);
  if (!error) {
    std::vector<int64_t> devices;
    const auto addressable = args->executable->get()->addressable_devices();
    for (size_t d = 0; d < args->num_devices; ++d)
      devices.push_back(args->execute_device
                            ? args->execute_device->device->id()
                            : addressable[d]->id());
    const auto runtime = Runtime(args->executable->client);
    profile.activity().SetProgram(work.program_id, args->num_devices,
                                  work.num_replicas);
    const std::string name(args->executable->get()->name());
    std::vector<Completion> completed = runtime->ExecuteTimed(
        work.bundle_timing.duration_ns, work.bundle_timing.cost_gaps != 0,
        devices, dependencies, profile.activity(), name);

    for (size_t d = 0; d < args->num_devices; ++d) {
      execute_args.device_complete_events[d]->future =
          JoinFutures({completed[d].future,
                       execute_args.device_complete_events[d]->future});
      for (size_t output = 0; output < types.front().size(); ++output)
        SetProducer(args->output_lists[d][output], completed[d]);
    }
  }
  if (!error && profile.activity()) {
    const auto devices = args->executable->get()->addressable_devices();
    for (size_t i = 0; i < args->num_devices; ++i) {
      const int64_t device = args->execute_device
                                 ? args->execute_device->device->id()
                                 : devices[i]->id();
      profile.activity().Ready(execute_args.device_complete_events[i]->future,
                               "Execute submit-to-ready", device);
    }
  }
  for (PJRT_Event* event : owned_events) delete event;
  if (error) {
    profile.activity().Finish(
        pjrt::PjrtErrorToStatus(error, pjrt::cpu_plugin::GetCpuPjrtApi()));
    return error;
  }
  std::lock_guard<std::mutex> lock(State().mutex);
  std::string outputs;
  for (size_t device = 0; device < args->num_devices; ++device) {
    for (size_t output = 0; output < types.front().size(); ++output) {
      const uint64_t id = TrackLocked(args->output_lists[device][output]);
      if (profile.activity()) AppendId(outputs, id);
    }
  }
  profile.activity().SetLinks(std::move(inputs), std::move(outputs));
  const auto it = State().work.find(args->executable);
  if (it != State().work.end()) {
    const ExecutableWork& work = it->second;
    profile.activity().SetProgram(work.program_id, args->num_devices,
                                  work.num_replicas);
  }
  if (it != State().work.end() && State().trace.is_open()) {
    const ExecutableWork& work = it->second;
    State().trace << std::setprecision(17)
                  << "{\"sequence\":" << State().sequence++ << ",\"name\":"
                  << std::quoted(std::string(args->executable->get()->name()))
                  << ",\"num_devices\":" << args->num_devices
                  << ",\"num_replicas\":" << work.num_replicas
                  << ",\"num_partitions\":" << work.num_partitions
                  << ",\"analysis_source\":" << std::quoted("libtpu_bundles")
                  << ",\"program_id\":" << work.program_id
                  << ",\"correlation_id\":"
                  << profile.activity().correlation_id()
                  << ",\"work_scope\":" << std::quoted("per_partition")
                  << ",\"substituted_ops\":" << work.substituted_ops;
    State().trace << ",\"bundle_duration_ns\":"
                  << work.bundle_timing.duration_ns
                  << ",\"bundle_count\":" << work.bundle_timing.bundles
                  << ",\"bundle_cost_gaps\":" << work.bundle_timing.cost_gaps;
    State().trace << "}\n";
    State().trace.flush();
    if (!State().trace) LOG(ERROR) << "Failed to write PJRT_SIM_TRACE";
  }
  return nullptr;
}

PJRT_Error* DestroyExecutable(PJRT_LoadedExecutable_Destroy_Args* args) {
  {
    std::lock_guard<std::mutex> lock(State().mutex);
    State().work.erase(args->executable);
  }
  return pjrt::PJRT_LoadedExecutable_Destroy(args);
}

}  // namespace

int64_t MaxMaterializedBytes(PJRT_Client* client) {
  auto runtime = Runtime(client);
  return runtime ? runtime->max_materialized_bytes() : 0;
}

void RegisterWork(PJRT_LoadedExecutable* executable, ExecutableWork work,
                  const std::string& program_json) {
  std::lock_guard<std::mutex> lock(State().mutex);
  work.program_id = State().next_program_id++;
  if (!program_json.empty()) {
    const char* prefix = std::getenv("PJRT_SIM_TRACE");
    if (prefix) {
      std::ofstream program(
          std::string(prefix) + "." +
          std::to_string(tsl::Env::Default()->GetProcessId()) + ".program" +
          std::to_string(work.program_id) + ".json");
      program << program_json << '\n';
      program.flush();
      if (!program) LOG(ERROR) << "Failed to write simulator program snapshot";
    }
  }
  State().work.emplace(executable, std::move(work));
}

void RegisterRuntime(PJRT_Client* client, RuntimeConfig config) {
  std::lock_guard<std::mutex> lock(State().mutex);
  State().runtimes.emplace(client, std::make_shared<SimRuntime>(config));
}

void AddInstrumentation(PJRT_Api& api) {
  // Even small CPU-backed control values are simulated device memory. Force
  // frameworks through D2H so host reads receive transfer timing and events.
  api.PJRT_Buffer_IsOnCpu = [](PJRT_Buffer_IsOnCpu_Args* args) -> PJRT_Error* {
    PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
        "PJRT_Buffer_IsOnCpu_Args", PJRT_Buffer_IsOnCpu_Args_STRUCT_SIZE,
        args->struct_size));
    args->is_on_cpu = false;
    return nullptr;
  };
  api.PJRT_Client_Destroy = DestroyClient;
  api.PJRT_Client_BufferFromHostBuffer = FromHost;
  api.PJRT_Buffer_CopyToMemory = Copy;
  api.PJRT_Buffer_CopyToDevice = CopyToDevice;
  api.PJRT_Buffer_UnsafePointer = UnsafePointer;
  api.PJRT_Buffer_OpaqueDeviceMemoryDataPointer = OpaquePointer;
  api.PJRT_Buffer_Bitcast = Bitcast;
  api.PJRT_Buffer_ToHostBuffer = ToHost;
  api.PJRT_Buffer_CopyRawToHost = RawToHost;
  api.PJRT_Buffer_IncreaseExternalReferenceCount = ExternalReference;
  api.PJRT_Buffer_ReadyEvent = ReadyEvent;
  api.PJRT_Buffer_Destroy = DestroyBuffer;
  api.PJRT_Device_MemoryStats = MemoryStats;
  api.PJRT_LoadedExecutable_Execute = Execute;
  api.PJRT_LoadedExecutable_Destroy = DestroyExecutable;
  // These allocation/import APIs need producer-state adapters before they can
  // participate in online simulation. Do not silently bypass readiness gates.
  api.PJRT_Client_CreateViewOfDeviceBuffer =
      [](PJRT_Client_CreateViewOfDeviceBuffer_Args*) {
        return pjrt::StatusToPjRtError(
            absl::UnimplementedError("Simulator buffer import is unsupported"));
      };
  api.PJRT_Client_CreateBuffersForAsyncHostToDevice =
      [](PJRT_Client_CreateBuffersForAsyncHostToDevice_Args*) {
        return pjrt::StatusToPjRtError(absl::UnimplementedError(
            "Simulator async buffer allocation is unsupported"));
      };
  api.PJRT_Buffer_DonateWithControlDependency =
      [](PJRT_Buffer_DonateWithControlDependency_Args*) {
        return pjrt::StatusToPjRtError(absl::UnimplementedError(
            "Simulator explicit control donation is unsupported"));
      };
}

}  // namespace xla::sim
