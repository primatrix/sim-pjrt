#include "src/virtual_hbm.h"

#include <cstring>
#include <utility>
#include <vector>

#include "absl/container/inlined_vector.h"
#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "absl/synchronization/blocking_counter.h"
#include "src/hlo_utils.h"
#include "tsl/platform/env.h"
#include "xla/hlo/builder/xla_computation.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/hlo/transforms/simplifiers/hlo_dce.h"
#include "xla/layout_util.h"
#include "xla/literal_util.h"
#include "xla/pjrt/c/pjrt_c_api_helpers.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"
#include "xla/pjrt/common_pjrt_client.h"
#include "xla/pjrt/host_callback.h"
#include "xla/primitive_util.h"
#include "xla/service/computation_layout.h"
#include "xla/shape_util.h"

namespace xla::sim {
namespace {
ExecuteOptions OutputExecutionOptions(ExecuteOptions options) {
  // Placeholder programs look cheap to the CPU backend, which would otherwise
  // run them inline even with an asynchronous client.
  if (options.execution_mode == ExecuteOptions::ExecutionMode::kDefault)
    options.execution_mode = ExecuteOptions::ExecutionMode::kAsynchronous;
  return options;
}

void ZeroWhenReady(Future<> ready, void* destination, int64_t size,
                   Promise<> promise) {
  ready.OnReady([destination, size, promise = std::move(promise)](
                    absl::Status status) mutable {
    tsl::Env::Default()->SchedClosure(
        [destination, size, promise = std::move(promise), status]() mutable {
          if (status.ok() && size) std::memset(destination, 0, size);
          promise.Set(status);
        });
  });
}

Shape PhysicalShape(Shape shape) {
  if (shape.IsTuple()) {
    for (Shape &child : *shape.mutable_tuple_shapes())
      child = PhysicalShape(child);
  } else if (shape.IsArray() &&
             primitive_util::IsFloatingPointType(shape.element_type()) &&
             ShapeUtil::ElementsIn(shape) != 1) {
    return ShapeUtil::MakeShape(shape.element_type(), {});
  }
  return shape;
}
bool HasPlaceholder(const Shape &shape) {
  if (shape.IsTuple()) {
    for (const Shape &child : shape.tuple_shapes()) {
      if (HasPlaceholder(child))
        return true;
    }
    return false;
  }
  return shape.IsArray() &&
         primitive_util::IsFloatingPointType(shape.element_type()) &&
         ShapeUtil::ElementsIn(shape) != 1;
}
HloInstruction *Zero(HloComputation *computation, const Shape &shape) {
  if (shape.IsTuple()) {
    std::vector<HloInstruction *> children;
    for (const Shape &child : shape.tuple_shapes()) {
      children.push_back(Zero(computation, child));
    }
    return computation->AddInstruction(HloInstruction::CreateTuple(children));
  }
  auto *zero = computation->AddInstruction(
      HloInstruction::CreateConstant(LiteralUtil::Zero(shape.element_type())));
  if (shape.dimensions_size() == 0)
    return zero;
  return computation->AddInstruction(
      HloInstruction::CreateBroadcast(shape, zero, {}));
}
absl::Status NoData() {
  return absl::FailedPreconditionError(
      "Virtual HBM has no materialized data on device; pointer export is "
      "unavailable; use D2H for simulated data");
}

bool CompatibleBufferShape(const Shape& actual, const Shape& expected) {
  // Static arrays are the common Virtual HBM case. Avoid the general recursive
  // comparator while keeping its fallback for dynamic and non-array shapes.
  if (actual.IsArrayExcludingBuffer() && expected.IsArrayExcludingBuffer() &&
      actual.is_static() &&
      expected.is_static())
    return actual.element_type() == expected.element_type() &&
           actual.dimensions() == expected.dimensions();
  return ShapeUtil::Compatible(actual, expected);
}

class VirtualBuffer final : public PjRtBuffer {
public:
  VirtualBuffer(std::unique_ptr<PjRtBuffer> storage, Shape shape)
      : storage_(std::move(storage)), shape_(std::move(shape)) {
    if (!shape_.has_layout())
      LayoutUtil::SetToDefaultLayout(&shape_);
  }
  PjRtBuffer *storage() const { return storage_.get(); }
  const Shape &on_device_shape() const override { return shape_; }
  PjRtMemorySpace *memory_space() const override {
    return storage_->memory_space();
  }
  PjRtDevice *device() const override { return storage_->device(); }
  PjRtClient *client() const override { return storage_->client(); }
  absl::StatusOr<size_t> GetOnDeviceSizeInBytes() const override {
    return ShapeUtil::ByteSizeOf(shape_);
  }
  Future<> GetReadyFuture() override { return storage_->GetReadyFuture(); }
  void Delete() override { storage_->Delete(); }
  bool IsDeleted() const override { return storage_->IsDeleted(); }
  bool IsOnCpu() const override { return false; }
  absl::StatusOr<std::unique_ptr<ExternalReference>>
  AcquireExternalReference() override {
    return NoData();
  }
  absl::StatusOr<std::unique_ptr<ExternalReference>>
  ReleaseDeviceMemoryOwnership(bool) override {
    return NoData();
  }
  Future<> ToLiteral(MutableLiteralBase *literal) override {
    if (!literal || !ShapeUtil::Compatible(shape_, literal->shape())) {
      return Future<>(absl::InvalidArgumentError("Virtual D2H shape mismatch"));
    }
    if (!HasPlaceholder(shape_))
      return storage_->ToLiteral(literal);
    return CopyRawToHost(literal->untyped_data(), 0, literal->size_bytes());
  }
  Future<> LazyToLiteral(absl::AnyInvocable<Future<MutableLiteralBase *>() &&>
                             generator) override {
    if (!HasPlaceholder(shape_))
      return storage_->LazyToLiteral(std::move(generator));
    auto [promise, future] = MakePromise();
    // Do not retain this buffer across asynchronous callbacks.
    auto ready = storage_->GetReadyFuture();
    Shape shape = shape_;
    // The generator may allocate a large host literal as well.
    tsl::Env::Default()->SchedClosure(
        [generator = std::move(generator), promise = std::move(promise),
         ready, shape]() mutable {
      std::move(generator)().OnReady(
        [promise = std::move(promise), ready,
         shape](absl::StatusOr<MutableLiteralBase *> result) mutable {
          if (!result.ok()) {
            promise.Set(result.status());
            return;
          }
          auto *literal = *result;
          if (!literal || !ShapeUtil::Compatible(shape, literal->shape())) {
            promise.Set(
                absl::InvalidArgumentError("Virtual D2H shape mismatch"));
            return;
          }
          ZeroWhenReady(ready, literal->untyped_data(), literal->size_bytes(),
                        std::move(promise));
        });
    });
    return future;
  }
  Future<> CopyRawToHost(void *destination, int64_t offset,
                         int64_t size) override {
    const int64_t bytes = ShapeUtil::ByteSizeOfElements(shape_);
    if (offset < 0 || size < 0 || offset > bytes || size > bytes - offset ||
        (size && !destination)) {
      return Future<>(
          absl::InvalidArgumentError("Virtual D2H range is invalid"));
    }
    if (!HasPlaceholder(shape_))
      return storage_->CopyRawToHost(destination, offset, size);
    auto [promise, future] = MakePromise();
    ZeroWhenReady(storage_->GetReadyFuture(), destination, size,
                  std::move(promise));
    return future;
  }
  void CopyToRemoteDevice(Future<std::string>,
                          RemoteSendCallback on_done) override {
    on_done(absl::UnimplementedError("Virtual remote copies are unsupported"),
            false);
  }
  absl::StatusOr<std::unique_ptr<PjRtBuffer>>
  CopyToMemorySpace(PjRtMemorySpace *memory) override {
    ABSL_ASSIGN_OR_RETURN(auto copy, storage_->CopyToMemorySpace(memory));
    return std::make_unique<VirtualBuffer>(std::move(copy), shape_);
  }
  absl::StatusOr<std::unique_ptr<PjRtBuffer>>
  Bitcast(PrimitiveType, absl::Span<const int64_t>, const Layout *) override {
    return absl::UnimplementedError(
        "Virtual buffer bitcast is unsupported; use a compiled reshape");
  }

private:
  std::unique_ptr<PjRtBuffer> storage_;
  Shape shape_;
};

// Derive public layouts and shapes from the logical module, never the scalar
// CPU program. CPU memory-analysis numbers would be misleading, so the default
// unsupported response is retained for compiled memory statistics.
class LogicalExecutable final : public PjRtExecutable {
public:
  LogicalExecutable(PjRtLoadedExecutable *physical,
                    std::shared_ptr<HloModule> logical, CompileOptions options,
                    std::vector<int64_t> parameters)
      : physical_(physical), logical_(std::move(logical)),
        options_(std::move(options)), parameters_(std::move(parameters)) {}
  int num_replicas() const override { return physical_->num_replicas(); }
  int num_partitions() const override { return physical_->num_partitions(); }
  int64_t SizeOfGeneratedCodeInBytes() const override {
    return physical_->SizeOfGeneratedCodeInBytes();
  }
  absl::string_view name() const override { return logical_->name(); }
  absl::StatusOr<std::vector<std::shared_ptr<HloModule>>>
  GetHloModules() const override {
    return std::vector<std::shared_ptr<HloModule>>{logical_};
  }
  absl::StatusOr<std::vector<std::vector<absl::string_view>>>
  GetParameterMemoryKinds() const override {
    ABSL_ASSIGN_OR_RETURN(auto kinds, physical_->GetParameterMemoryKinds());
    ABSL_ASSIGN_OR_RETURN(
        auto memory,
        physical_->addressable_devices().front()->default_memory_space());
    std::vector<absl::string_view> logical_kinds(
        logical_->entry_computation()->num_parameters(), memory->kind());
    for (int i = 0; i < parameters_.size(); ++i)
      logical_kinds[parameters_[i]] = kinds.front()[i];
    return std::vector<std::vector<absl::string_view>>{std::move(logical_kinds)};
  }
  absl::StatusOr<std::vector<std::vector<absl::string_view>>>
  GetOutputMemoryKinds() const override {
    return physical_->GetOutputMemoryKinds();
  }
  absl::StatusOr<CompileOptions> GetCompileOptions() const override {
    return options_;
  }

private:
  PjRtLoadedExecutable *physical_;
  std::shared_ptr<HloModule> logical_;
  CompileOptions options_;
  std::vector<int64_t> parameters_;
};

class VirtualExecutable final : public PjRtLoadedExecutable {
public:
  VirtualExecutable(std::unique_ptr<PjRtLoadedExecutable> physical,
                    std::shared_ptr<HloModule> logical, CompileOptions options,
                    std::vector<int64_t> parameters)
      : physical_(std::move(physical)),
        metadata_(physical_.get(), logical, std::move(options), parameters),
        signature_(logical->entry_computation_layout().ComputeProgramShape()),
        parameters_(std::move(parameters)) {}
  PjRtExecutable *GetExecutable() const override { return &metadata_; }
  PjRtClient *client() const override { return physical_->client(); }
  const DeviceAssignment &device_assignment() const override {
    return physical_->device_assignment();
  }
  absl::Span<const LogicalDeviceIds>
  addressable_device_logical_ids() const override {
    return physical_->addressable_device_logical_ids();
  }
  absl::Span<PjRtDevice *const> addressable_devices() const override {
    return physical_->addressable_devices();
  }
  void Delete() override { physical_->Delete(); }
  bool IsDeleted() const override { return physical_->IsDeleted(); }
  absl::StatusOr<std::vector<std::vector<std::unique_ptr<PjRtBuffer>>>>
  Execute(absl::Span<const std::vector<PjRtBuffer *>> arguments,
          const ExecuteOptions &options,
          std::optional<std::vector<Future<>>> &futures) const override {
    std::vector<std::vector<PjRtBuffer *>> unwrapped(arguments.size());
    auto* common = dynamic_cast<CommonPjRtClient*>(client());
    // Amortize pool dispatch for large signatures. Reuse the backend's workers;
    // never create per-execution threads or schedule recursively in a callback.
    constexpr int kParallelPrepareMinArgs = 256;
    if (arguments.size() > 1 &&
        signature_.parameters_size() >= kParallelPrepareMinArgs && common &&
        common->async_work_runner() && !ThisThreadIsInsideHostCallback()) {
      absl::BlockingCounter done(arguments.size());
      std::vector<absl::Status> status(arguments.size());
      for (size_t i = 0; i < arguments.size(); ++i) {
        common->async_work_runner()->Execute([&, i] {
          auto args = Unwrap(arguments[i]);
          if (args.ok()) unwrapped[i] = std::move(*args);
          else status[i] = args.status();
          done.DecrementCount();
        });
      }
      // Wait for input validation, not device execution. All workers must finish
      // before returning an error or releasing the borrowed argument pointers.
      done.Wait();
      for (const auto& result : status) ABSL_RETURN_IF_ERROR(result);
    } else {
      for (size_t i = 0; i < arguments.size(); ++i) {
        ABSL_ASSIGN_OR_RETURN(unwrapped[i], Unwrap(arguments[i]));
      }
    }
    ABSL_ASSIGN_OR_RETURN(
        auto outputs,
        physical_->Execute(unwrapped, PhysicalOptions(options), futures));
    for (auto &device_outputs : outputs)
      Wrap(device_outputs);
    return outputs;
  }
  absl::StatusOr<std::vector<std::unique_ptr<PjRtBuffer>>>
  ExecuteSharded(absl::Span<PjRtBuffer *const> arguments, PjRtDevice *device,
                 const ExecuteOptions &options, std::optional<Future<>> &future,
                 bool fill) const override {
    ABSL_ASSIGN_OR_RETURN(auto args, Unwrap(arguments));
    ABSL_ASSIGN_OR_RETURN(
        auto outputs,
        physical_->ExecuteSharded(args, device, PhysicalOptions(options),
                                  future, fill));
    Wrap(outputs);
    return outputs;
  }
  absl::StatusOr<std::vector<std::unique_ptr<PjRtBuffer>>>
  ExecutePortable(absl::Span<PjRtBuffer *const> arguments, PjRtDevice *device,
                  const ExecuteOptions &options,
                  std::optional<Future<>> &future, bool fill) const override {
    ABSL_ASSIGN_OR_RETURN(auto args, Unwrap(arguments));
    ABSL_ASSIGN_OR_RETURN(
        auto outputs,
        physical_->ExecutePortable(args, device, PhysicalOptions(options),
                                   future, fill));
    Wrap(outputs);
    return outputs;
  }

private:
  ExecuteOptions PhysicalOptions(const ExecuteOptions& options) const {
    auto physical = OutputExecutionOptions(options);
    physical.non_donatable_input_indices.clear();
    for (int i = 0; i < parameters_.size(); ++i)
      if (options.non_donatable_input_indices.contains(parameters_[i]))
        physical.non_donatable_input_indices.insert(i);
    return physical;
  }
  absl::StatusOr<std::vector<PjRtBuffer *>>
  Unwrap(absl::Span<PjRtBuffer *const> arguments) const {
    if (arguments.size() != signature_.parameters_size()) {
      return absl::InvalidArgumentError(
          "Virtual executable argument count mismatch");
    }
    std::vector<PjRtBuffer *> result;
    result.reserve(parameters_.size());
    for (int i = 0; i < arguments.size(); ++i) {
      PjRtBuffer *buffer = arguments[i];
      const Shape &expected = signature_.parameters(i);
      auto *virtual_buffer = dynamic_cast<VirtualBuffer *>(buffer);
      if (!CompatibleBufferShape(buffer->on_device_shape(), expected) ||
          !virtual_buffer || virtual_buffer->IsDeleted()) {
        return absl::InvalidArgumentError(
            "Virtual executable argument storage or shape mismatch");
      }
    }
    for (int64_t parameter : parameters_) {
      result.push_back(
          static_cast<VirtualBuffer*>(arguments[parameter])->storage());
    }
    return result;
  }
  void Wrap(std::vector<std::unique_ptr<PjRtBuffer>> &outputs) const {
    for (int i = 0; i < outputs.size(); ++i) {
      const Shape &shape = signature_.result().IsTuple()
                               ? signature_.result().tuple_shapes(i)
                               : signature_.result();
      outputs[i] =
          std::make_unique<VirtualBuffer>(std::move(outputs[i]), shape);
    }
  }
  std::unique_ptr<PjRtLoadedExecutable> physical_;
  mutable LogicalExecutable metadata_;
  ProgramShape signature_;
  std::vector<int64_t> parameters_;
};
// Keep the public signature intact; only the CPU placeholder program drops
// dead inputs. Aliases, donors and nondefault memory layouts retain their inputs.
absl::StatusOr<std::vector<int64_t>> PruneCpuParameters(
    HloModule& module, CompileOptions& options) {
  ABSL_RETURN_IF_ERROR(HloDCE().Run(&module).status());
  auto* entry = module.entry_computation();
  std::vector<int64_t> parameters;
  // RemoveParameter renumbers later parameters without moving control edges.
  for (auto* parameter : entry->parameter_instructions()) {
    if (parameter->HasControlDependencies()) {
      for (int64_t i = 0; i < entry->num_parameters(); ++i)
        parameters.push_back(i);
      return parameters;
    }
  }
  std::vector<int64_t> remap(entry->num_parameters(), -1);
  for (auto* parameter : entry->parameter_instructions()) {
    const int64_t i = parameter->parameter_number();
    const auto& shape = parameter->shape();
    if (!parameter->IsDead() ||
        module.input_output_alias_config().ParameterHasAlias(i, {}) ||
        module.buffer_donor_config().ParameterIsBufferDonor(i, {}) ||
        (shape.has_layout() && shape.layout().memory_space() != 0)) {
      remap[i] = parameters.size();
      parameters.push_back(i);
    }
  }
  HloInputOutputAliasConfig aliases(entry->root_instruction()->shape());
  ABSL_RETURN_IF_ERROR(module.input_output_alias_config().ForEachAliasWithStatus(
      [&](const ShapeIndex& output, const HloInputOutputAliasConfig::Alias& alias) {
        return aliases.SetUpAlias(output, remap[alias.parameter_number],
                                  alias.parameter_index, alias.kind);
      }));
  HloBufferDonorConfig donors;
  for (const auto& donor : module.buffer_donor_config().buffer_donor())
    ABSL_RETURN_IF_ERROR(donors.AddBufferDonor(remap[donor.param_number],
                                             donor.param_index));
  for (int64_t i = remap.size(); i-- > 0;)
    if (remap[i] < 0) ABSL_RETURN_IF_ERROR(entry->RemoveParameter(i));
  module.input_output_alias_config() = std::move(aliases);
  module.buffer_donor_config() = std::move(donors);
  *module.mutable_entry_computation_layout() =
      ComputationLayout(entry->ComputeProgramShape());
  if (options.argument_layouts) {
    std::vector<Shape> layouts;
    for (int64_t i : parameters) layouts.push_back((*options.argument_layouts)[i]);
    options.argument_layouts = std::move(layouts);
  }
  auto& build = options.executable_build_options;
  const auto propagation = build.allow_spmd_sharding_propagation_to_parameters();
  if (propagation.size() > 1) {
    if (propagation.size() != remap.size())
      return absl::InvalidArgumentError("Parameter propagation count mismatch");
    absl::InlinedVector<bool, 1> selected;
    for (int64_t i : parameters) selected.push_back(propagation[i]);
    build.set_allow_spmd_sharding_propagation_to_parameters(selected);
  }
  return parameters;
}
} // namespace

absl::StatusOr<PjRtRawBufferRef> VirtualRawAlias(
    PjRtBuffer* buffer, std::shared_ptr<SimRuntime> runtime, Completion ready) {
  const auto& shape = buffer->on_device_shape();
  if (!shape.IsArray() || shape.is_dynamic())
    return absl::UnimplementedError("RawBuffer requires a static array");
  ABSL_ASSIGN_OR_RETURN(auto bytes, buffer->GetOnDeviceSizeInBytes());
  if (auto* virtual_buffer = dynamic_cast<VirtualBuffer*>(buffer))
    return MakeRawAlias(virtual_buffer->storage(), bytes, HasPlaceholder(shape),
                        std::move(runtime), std::move(ready));
  return MakeRawAlias(buffer, bytes, false, std::move(runtime), std::move(ready));
}

absl::Status VirtualizeModule(HloModule &module) {
  for (HloComputation *computation : module.computations()) {
    for (HloInstruction *instruction : computation->instructions()) {
      ABSL_RETURN_IF_ERROR(ShapeUtil::ForEachSubshapeWithStatus(
          instruction->shape(),
          [&](const Shape &shape, const ShapeIndex &) -> absl::Status {
            if (shape.is_dynamic())
              return absl::UnimplementedError(
                  "Virtual HBM requires static shapes");
            return absl::OkStatus();
          }));
    }
  }
  // Mutate shapes first, then replace nonstructural operations whose signatures
  // changed. Keep unused operands until iteration ends so pointers stay valid.
  for (HloComputation *computation : module.MakeComputationPostOrder()) {
    auto instructions = computation->MakeInstructionPostOrder();
    std::vector<HloInstruction *> replace;
    for (HloInstruction *instruction : instructions) {
      bool changed = !ShapeUtil::Compatible(
          instruction->shape(), PhysicalShape(instruction->shape()));
      for (HloInstruction *operand : instruction->operands()) {
        changed |= !ShapeUtil::Compatible(operand->shape(),
                                          PhysicalShape(operand->shape()));
      }
      if (!changed)
        continue;
      switch (instruction->opcode()) {
      case HloOpcode::kParameter:
      case HloOpcode::kTuple:
      case HloOpcode::kGetTupleElement:
      case HloOpcode::kCall:
      case HloOpcode::kWhile:
      case HloOpcode::kConditional:
        break;
      default:
        if (instruction->HasSideEffect() &&
            !IsShardingAnnotation(*instruction)) {
          return absl::UnimplementedError(absl::StrCat(
              "Unsupported virtual operation: ", instruction->ToString()));
        }
        replace.push_back(instruction);
      }
    }
    for (HloInstruction *instruction : instructions) {
      *instruction->mutable_shape() = PhysicalShape(instruction->shape());
      instruction->clear_sharding();
    }
    for (HloInstruction *instruction : replace) {
      ABSL_ASSIGN_OR_RETURN(bool replaced,
                            computation->ReplaceInstructionWithDifferentShape(
                                instruction,
                                Zero(computation, instruction->shape()), false,
                                true, false));
      (void)replaced;
    }
  }
  *module.mutable_entry_computation_layout() =
      ComputationLayout(module.entry_computation()->ComputeProgramShape());
  return absl::OkStatus();
}

absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>>
CompileVirtual(PjRtClient *client, std::unique_ptr<HloModule> module,
               CompileOptions options) {
  if (options.executable_build_options.num_replicas() != 1 ||
      options.parameter_is_tupled_arguments) {
    return absl::UnimplementedError(
        "Virtual HBM requires one replica and untupled "
        "parameters");
  }
  for (const HloInstruction *parameter :
       module->entry_computation()->parameter_instructions()) {
    if (parameter->shape().IsTuple()) {
      return absl::UnimplementedError(
          "Virtual HBM does not support tuple parameters");
    }
  }
  const Shape &result =
      module->entry_computation()->root_instruction()->shape();
  if (result.IsTuple()) {
    for (const Shape &child : result.tuple_shapes()) {
      if (child.IsTuple()) {
        return absl::UnimplementedError(
            "Virtual HBM does not support nested tuple results");
      }
    }
  }
  std::shared_ptr<HloModule> logical = module->Clone();
  logical->set_name(module->name());
  if (options.argument_layouts) {
    if (options.argument_layouts->size() !=
        logical->entry_computation()->num_parameters()) {
      return absl::InvalidArgumentError(
          "Virtual argument layout count mismatch");
    }
    for (int i = 0; i < options.argument_layouts->size(); ++i) {
      const Shape &shape = (*options.argument_layouts)[i];
      if (LayoutUtil::HasLayout(shape)) {
        *logical->mutable_entry_computation_layout()->mutable_parameter_layout(
            i) = ShapeLayout(shape);
      }
    }
  }
  if (const Shape *shape = options.executable_build_options.result_layout();
      shape && LayoutUtil::HasLayout(*shape)) {
    *logical->mutable_entry_computation_layout()->mutable_result_layout() =
        ShapeLayout(*shape);
  }
  CompileOptions logical_options = options;
  ABSL_RETURN_IF_ERROR(VirtualizeModule(*module));
  if (options.argument_layouts) {
    for (Shape &shape : *options.argument_layouts)
      shape = PhysicalShape(shape);
  }
  if (const Shape *layout = options.executable_build_options.result_layout()) {
    options.executable_build_options.set_result_layout(PhysicalShape(*layout));
  }
  ABSL_ASSIGN_OR_RETURN(auto parameters, PruneCpuParameters(*module, options));
  ABSL_ASSIGN_OR_RETURN(
      auto physical, client->CompileAndLoad(XlaComputation(module->ToProto()),
                                            std::move(options)));
  return std::make_unique<VirtualExecutable>(
      std::move(physical), std::move(logical), std::move(logical_options),
      std::move(parameters));
}

PJRT_Error *VirtualFromHost(PJRT_Client_BufferFromHostBuffer_Args *args) {
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_BufferFromHostBuffer_Args",
      PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE, args->struct_size));
  PJRT_ASSIGN_OR_RETURN(Shape shape, pjrt::BuildXlaShapeFromC(
                                         args->type, args->dims, args->num_dims,
                                         args->device_layout));
  if (!HasPlaceholder(shape)) {
    // Integer, boolean and single-value float control state lives on the host.
    // SGLang uses f32[1] for its distributed available-memory query.
    if (auto *error = pjrt::PJRT_Client_BufferFromHostBuffer(args))
      return error;
    args->buffer->buffer = std::make_unique<VirtualBuffer>(
        std::move(args->buffer->buffer), std::move(shape));
    return nullptr;
  }
  // The source payload is intentionally never read. CPU copies the scalar
  // during this call, so neither the local zero nor the host source is
  // retained.
  uint64_t zero = 0;
  PjRtMemorySpace *memory;
  if (args->memory)
    memory = PjRtMemorySpace::FromC(args->memory);
  else {
    PJRT_ASSIGN_OR_RETURN(memory, args->device->device->default_memory_space());
  }
  PJRT_ASSIGN_OR_RETURN(
      auto storage,
      args->client->client->BufferFromHostBuffer(
          &zero, shape.element_type(), {}, std::nullopt,
          PjRtClient::HostBufferSemantics::kImmutableOnlyDuringCall, nullptr,
          memory, nullptr));
  args->buffer = new PJRT_Buffer{
      std::make_unique<VirtualBuffer>(std::move(storage), std::move(shape)),
      args->client};
  args->done_with_host_buffer = new PJRT_Event{Future<>(absl::OkStatus())};
  return nullptr;
}
absl::Status CheckMaterialized(PjRtBuffer *buffer) {
  return dynamic_cast<VirtualBuffer *>(buffer) ? NoData() : absl::OkStatus();
}
} // namespace xla::sim
