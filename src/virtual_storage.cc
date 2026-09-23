#include "src/virtual_storage.h"

#include <utility>
#include <vector>

#include "absl/status/status_macros.h"
#include "absl/strings/str_cat.h"
#include "xla/hlo/builder/xla_computation.h"
#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/layout_util.h"
#include "xla/literal_util.h"
#include "xla/pjrt/c/pjrt_c_api_helpers.h"
#include "xla/pjrt/c/pjrt_c_api_status_utils.h"
#include "xla/pjrt/c/pjrt_c_api_wrapper_impl.h"
#include "xla/primitive_util.h"
#include "xla/service/computation_layout.h"
#include "xla/shape_util.h"

namespace xla::sim {
namespace {
bool Large(const Shape& shape, int64_t limit) {
  return shape.IsArray() && ShapeUtil::ByteSizeOf(shape) > limit;
}
Shape PhysicalShape(Shape shape, int64_t limit) {
  if (shape.IsTuple()) {
    for (Shape& child : *shape.mutable_tuple_shapes()) {
      child = PhysicalShape(child, limit);
    }
  } else if (Large(shape, limit) &&
             primitive_util::IsFloatingPointType(shape.element_type())) {
    return ShapeUtil::MakeShape(shape.element_type(), {});
  }
  return shape;
}
bool HasFloat(const Shape& shape) {
  if (shape.IsTuple()) {
    for (const Shape& child : shape.tuple_shapes()) {
      if (HasFloat(child)) return true;
    }
    return false;
  }
  return shape.IsArray() &&
         primitive_util::IsFloatingPointType(shape.element_type());
}
bool AllFloat(const Shape& shape) {
  if (shape.IsTuple()) {
    for (const Shape& child : shape.tuple_shapes()) {
      if (!AllFloat(child)) return false;
    }
    return true;
  }
  return HasFloat(shape);
}
HloInstruction* Zero(HloComputation* computation, const Shape& shape) {
  if (shape.IsTuple()) {
    std::vector<HloInstruction*> children;
    for (const Shape& child : shape.tuple_shapes()) {
      children.push_back(Zero(computation, child));
    }
    return computation->AddInstruction(HloInstruction::CreateTuple(children));
  }
  auto* zero = computation->AddInstruction(
      HloInstruction::CreateConstant(LiteralUtil::Zero(shape.element_type())));
  if (shape.dimensions_size() == 0) return zero;
  return computation->AddInstruction(
      HloInstruction::CreateBroadcast(shape, zero, {}));
}
absl::Status NoData() {
  return absl::FailedPreconditionError(
      "Virtual simulator tensor has no materialized data; host reads and "
      "pointer export are unavailable");
}

class VirtualBuffer final : public PjRtBuffer {
 public:
  VirtualBuffer(std::unique_ptr<PjRtBuffer> storage, Shape shape)
      : storage_(std::move(storage)), shape_(std::move(shape)) {
    if (!shape_.has_layout()) LayoutUtil::SetToDefaultLayout(&shape_);
  }
  PjRtBuffer* storage() const { return storage_.get(); }
  const Shape& on_device_shape() const override { return shape_; }
  PjRtMemorySpace* memory_space() const override {
    return storage_->memory_space();
  }
  PjRtDevice* device() const override { return storage_->device(); }
  PjRtClient* client() const override { return storage_->client(); }
  absl::StatusOr<size_t> GetOnDeviceSizeInBytes() const override {
    return ShapeUtil::ByteSizeOf(shape_);
  }
  Future<> GetReadyFuture() override { return storage_->GetReadyFuture(); }
  void Delete() override { storage_->Delete(); }
  bool IsDeleted() const override { return storage_->IsDeleted(); }
  bool IsOnCpu() const override { return false; }
  absl::StatusOr<std::unique_ptr<ExternalReference>> AcquireExternalReference()
      override {
    return NoData();
  }
  absl::StatusOr<std::unique_ptr<ExternalReference>>
  ReleaseDeviceMemoryOwnership(bool) override {
    return NoData();
  }
  Future<> ToLiteral(MutableLiteralBase*) override {
    return Future<>(NoData());
  }
  Future<> LazyToLiteral(
      absl::AnyInvocable<Future<MutableLiteralBase*>() &&>) override {
    return Future<>(NoData());
  }
  Future<> CopyRawToHost(void*, int64_t, int64_t) override {
    return Future<>(NoData());
  }
  void CopyToRemoteDevice(Future<std::string>,
                          RemoteSendCallback on_done) override {
    on_done(absl::UnimplementedError("Virtual remote copies are unsupported"),
            false);
  }
  absl::StatusOr<std::unique_ptr<PjRtBuffer>> CopyToMemorySpace(
      PjRtMemorySpace* memory) override {
    ABSL_ASSIGN_OR_RETURN(auto copy, storage_->CopyToMemorySpace(memory));
    return std::make_unique<VirtualBuffer>(std::move(copy), shape_);
  }
  absl::StatusOr<std::unique_ptr<PjRtBuffer>> Bitcast(PrimitiveType,
                                                      absl::Span<const int64_t>,
                                                      const Layout*) override {
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
  LogicalExecutable(PjRtLoadedExecutable* physical,
                    std::shared_ptr<HloModule> logical, CompileOptions options)
      : physical_(physical),
        logical_(std::move(logical)),
        options_(std::move(options)) {}
  int num_replicas() const override { return physical_->num_replicas(); }
  int num_partitions() const override { return physical_->num_partitions(); }
  int64_t SizeOfGeneratedCodeInBytes() const override {
    return physical_->SizeOfGeneratedCodeInBytes();
  }
  absl::string_view name() const override { return logical_->name(); }
  absl::StatusOr<std::vector<std::shared_ptr<HloModule>>> GetHloModules()
      const override {
    return std::vector<std::shared_ptr<HloModule>>{logical_};
  }
  absl::StatusOr<std::vector<std::vector<absl::string_view>>>
  GetParameterMemoryKinds() const override {
    return physical_->GetParameterMemoryKinds();
  }
  absl::StatusOr<std::vector<std::vector<absl::string_view>>>
  GetOutputMemoryKinds() const override {
    return physical_->GetOutputMemoryKinds();
  }
  absl::StatusOr<CompileOptions> GetCompileOptions() const override {
    return options_;
  }

 private:
  PjRtLoadedExecutable* physical_;
  std::shared_ptr<HloModule> logical_;
  CompileOptions options_;
};

class VirtualExecutable final : public PjRtLoadedExecutable {
 public:
  VirtualExecutable(std::unique_ptr<PjRtLoadedExecutable> physical,
                    std::shared_ptr<HloModule> logical, CompileOptions options,
                    int64_t limit)
      : physical_(std::move(physical)),
        metadata_(physical_.get(), logical, std::move(options)),
        signature_(logical->entry_computation_layout().ComputeProgramShape()),
        limit_(limit) {}
  PjRtExecutable* GetExecutable() const override { return &metadata_; }
  PjRtClient* client() const override { return physical_->client(); }
  const DeviceAssignment& device_assignment() const override {
    return physical_->device_assignment();
  }
  absl::Span<const LogicalDeviceIds> addressable_device_logical_ids()
      const override {
    return physical_->addressable_device_logical_ids();
  }
  absl::Span<PjRtDevice* const> addressable_devices() const override {
    return physical_->addressable_devices();
  }
  void Delete() override { physical_->Delete(); }
  bool IsDeleted() const override { return physical_->IsDeleted(); }
  absl::StatusOr<std::vector<std::vector<std::unique_ptr<PjRtBuffer>>>> Execute(
      absl::Span<const std::vector<PjRtBuffer*>> arguments,
      const ExecuteOptions& options,
      std::optional<std::vector<Future<>>>& futures) const override {
    std::vector<std::vector<PjRtBuffer*>> unwrapped;
    for (const auto& device_args : arguments) {
      ABSL_ASSIGN_OR_RETURN(auto args, Unwrap(device_args));
      unwrapped.push_back(std::move(args));
    }
    ABSL_ASSIGN_OR_RETURN(auto outputs,
                          physical_->Execute(unwrapped, options, futures));
    for (auto& device_outputs : outputs) Wrap(device_outputs);
    return outputs;
  }
  absl::StatusOr<std::vector<std::unique_ptr<PjRtBuffer>>> ExecuteSharded(
      absl::Span<PjRtBuffer* const> arguments, PjRtDevice* device,
      const ExecuteOptions& options, std::optional<Future<>>& future,
      bool fill) const override {
    ABSL_ASSIGN_OR_RETURN(auto args, Unwrap(arguments));
    ABSL_ASSIGN_OR_RETURN(
        auto outputs,
        physical_->ExecuteSharded(args, device, options, future, fill));
    Wrap(outputs);
    return outputs;
  }
  absl::StatusOr<std::vector<std::unique_ptr<PjRtBuffer>>> ExecutePortable(
      absl::Span<PjRtBuffer* const> arguments, PjRtDevice* device,
      const ExecuteOptions& options, std::optional<Future<>>& future,
      bool fill) const override {
    ABSL_ASSIGN_OR_RETURN(auto args, Unwrap(arguments));
    ABSL_ASSIGN_OR_RETURN(
        auto outputs,
        physical_->ExecutePortable(args, device, options, future, fill));
    Wrap(outputs);
    return outputs;
  }

 private:
  absl::StatusOr<std::vector<PjRtBuffer*>> Unwrap(
      absl::Span<PjRtBuffer* const> arguments) const {
    if (arguments.size() != signature_.parameters_size()) {
      return absl::InvalidArgumentError(
          "Virtual executable argument count mismatch");
    }
    std::vector<PjRtBuffer*> result;
    for (int i = 0; i < arguments.size(); ++i) {
      PjRtBuffer* buffer = arguments[i];
      const Shape& expected = signature_.parameters(i);
      auto* virtual_buffer = dynamic_cast<VirtualBuffer*>(buffer);
      if (!ShapeUtil::Compatible(buffer->on_device_shape(), expected) ||
          (Large(expected, limit_) != (virtual_buffer != nullptr))) {
        return absl::InvalidArgumentError(
            "Virtual executable argument storage or shape mismatch");
      }
      result.push_back(virtual_buffer ? virtual_buffer->storage() : buffer);
    }
    return result;
  }
  void Wrap(std::vector<std::unique_ptr<PjRtBuffer>>& outputs) const {
    for (int i = 0; i < outputs.size(); ++i) {
      const Shape& shape = signature_.result().IsTuple()
                               ? signature_.result().tuple_shapes(i)
                               : signature_.result();
      if (!ShapeUtil::Compatible(shape, PhysicalShape(shape, limit_))) {
        outputs[i] =
            std::make_unique<VirtualBuffer>(std::move(outputs[i]), shape);
      }
    }
  }
  std::unique_ptr<PjRtLoadedExecutable> physical_;
  mutable LogicalExecutable metadata_;
  ProgramShape signature_;
  int64_t limit_;
};
}  // namespace

absl::Status VirtualizeModule(HloModule& module, int64_t limit) {
  if (limit < 16)
    return absl::InvalidArgumentError(
        "Virtual storage limit must be at least 16 bytes");
  // Validate before any mutation. Conservatively forbid every float-to-control
  // boundary, including small intermediates and reducer computations, because
  // those values may originate from an approximated tensor in another call.
  for (HloComputation* computation : module.computations()) {
    for (HloInstruction* instruction : computation->instructions()) {
      ABSL_RETURN_IF_ERROR(ShapeUtil::ForEachSubshapeWithStatus(
          instruction->shape(),
          [&](const Shape& shape, const ShapeIndex&) -> absl::Status {
            if (shape.is_dynamic())
              return absl::UnimplementedError(
                  "Virtual storage requires static shapes");
            if (Large(shape, limit) && !HasFloat(shape)) {
              return absl::ResourceExhaustedError(
                  "Nonfloating tensor exceeds virtual storage materialization "
                  "limit");
            }
            return absl::OkStatus();
          }));
      switch (instruction->opcode()) {
        case HloOpcode::kParameter:
        case HloOpcode::kTuple:
        case HloOpcode::kGetTupleElement:
        case HloOpcode::kCall:
        case HloOpcode::kWhile:
        case HloOpcode::kConditional:
          break;
        default:
          for (const HloInstruction* operand : instruction->operands()) {
            if (HasFloat(operand->shape()) && !AllFloat(instruction->shape())) {
              return absl::UnimplementedError(
                  absl::StrCat("Virtual storage cannot derive integer/control "
                               "data from floating data: ",
                               instruction->name()));
            }
          }
      }
    }
  }
  // Mutate shapes first, then replace nonstructural operations whose signatures
  // changed. Keep unused operands until iteration ends so pointers stay valid.
  for (HloComputation* computation : module.MakeComputationPostOrder()) {
    auto instructions = computation->MakeInstructionPostOrder();
    std::vector<HloInstruction*> replace;
    for (HloInstruction* instruction : instructions) {
      bool changed = !ShapeUtil::Compatible(
          instruction->shape(), PhysicalShape(instruction->shape(), limit));
      for (HloInstruction* operand : instruction->operands()) {
        changed |= !ShapeUtil::Compatible(
            operand->shape(), PhysicalShape(operand->shape(), limit));
      }
      if (!changed) continue;
      switch (instruction->opcode()) {
        case HloOpcode::kParameter:
        case HloOpcode::kTuple:
        case HloOpcode::kGetTupleElement:
        case HloOpcode::kCall:
        case HloOpcode::kWhile:
        case HloOpcode::kConditional:
          break;
        default:
          if (!AllFloat(instruction->shape()) || instruction->HasSideEffect()) {
            return absl::UnimplementedError(absl::StrCat(
                "Unsupported virtual operation: ", instruction->name()));
          }
          replace.push_back(instruction);
      }
    }
    for (HloInstruction* instruction : instructions) {
      *instruction->mutable_shape() =
          PhysicalShape(instruction->shape(), limit);
      instruction->clear_sharding();
    }
    for (HloInstruction* instruction : replace) {
      ABSL_ASSIGN_OR_RETURN(
          bool replaced,
          computation->ReplaceInstructionWithDifferentShape(
              instruction, Zero(computation, instruction->shape()), false, true,
              false));
      (void)replaced;
    }
  }
  *module.mutable_entry_computation_layout() =
      ComputationLayout(module.entry_computation()->ComputeProgramShape());
  return absl::OkStatus();
}

absl::StatusOr<std::unique_ptr<PjRtLoadedExecutable>> CompileVirtual(
    PjRtClient* client, std::unique_ptr<HloModule> module,
    CompileOptions options, int64_t limit) {
  if (options.executable_build_options.num_replicas() != 1 ||
      options.parameter_is_tupled_arguments) {
    return absl::UnimplementedError(
        "Virtual storage requires one replica and untupled "
        "parameters");
  }
  for (const HloInstruction* parameter :
       module->entry_computation()->parameter_instructions()) {
    if (parameter->shape().IsTuple()) {
      return absl::UnimplementedError(
          "Virtual storage does not support tuple parameters");
    }
  }
  const Shape& result =
      module->entry_computation()->root_instruction()->shape();
  if (result.IsTuple()) {
    for (const Shape& child : result.tuple_shapes()) {
      if (child.IsTuple()) {
        return absl::UnimplementedError(
            "Virtual storage does not support nested tuple results");
      }
    }
  }
  std::shared_ptr<HloModule> logical = module->Clone();
  if (options.argument_layouts) {
    if (options.argument_layouts->size() !=
        logical->entry_computation()->num_parameters()) {
      return absl::InvalidArgumentError(
          "Virtual argument layout count mismatch");
    }
    for (int i = 0; i < options.argument_layouts->size(); ++i) {
      const Shape& shape = (*options.argument_layouts)[i];
      if (LayoutUtil::HasLayout(shape)) {
        *logical->mutable_entry_computation_layout()->mutable_parameter_layout(
            i) = ShapeLayout(shape);
      }
    }
  }
  if (const Shape* shape = options.executable_build_options.result_layout();
      shape && LayoutUtil::HasLayout(*shape)) {
    *logical->mutable_entry_computation_layout()->mutable_result_layout() =
        ShapeLayout(*shape);
  }
  CompileOptions logical_options = options;
  ABSL_RETURN_IF_ERROR(VirtualizeModule(*module, limit));
  if (options.argument_layouts) {
    for (Shape& shape : *options.argument_layouts)
      shape = PhysicalShape(shape, limit);
  }
  if (const Shape* layout = options.executable_build_options.result_layout()) {
    options.executable_build_options.set_result_layout(
        PhysicalShape(*layout, limit));
  }
  ABSL_ASSIGN_OR_RETURN(
      auto physical, client->CompileAndLoad(XlaComputation(module->ToProto()),
                                            std::move(options)));
  return std::make_unique<VirtualExecutable>(std::move(physical),
                                             std::move(logical),
                                             std::move(logical_options), limit);
}

PJRT_Error* VirtualFromHost(PJRT_Client_BufferFromHostBuffer_Args* args,
                            int64_t limit) {
  if (limit == 0) return pjrt::PJRT_Client_BufferFromHostBuffer(args);
  PJRT_RETURN_IF_ERROR(pjrt::ActualStructSizeIsGreaterOrEqual(
      "PJRT_Client_BufferFromHostBuffer_Args",
      PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE, args->struct_size));
  PJRT_ASSIGN_OR_RETURN(Shape shape, pjrt::BuildXlaShapeFromC(
                                         args->type, args->dims, args->num_dims,
                                         args->device_layout));
  if (!Large(shape, limit)) return pjrt::PJRT_Client_BufferFromHostBuffer(args);
  if (!HasFloat(shape))
    return pjrt::StatusToPjRtError(absl::ResourceExhaustedError(
        "Nonfloating tensor exceeds virtual storage materialization limit"));
  // The source payload is intentionally never read. CPU copies the scalar
  // during this call, so neither the local zero nor the host source is
  // retained.
  uint64_t zero = 0;
  PjRtMemorySpace* memory;
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
absl::Status CheckMaterialized(PjRtBuffer* buffer) {
  return dynamic_cast<VirtualBuffer*>(buffer) ? NoData() : absl::OkStatus();
}
}  // namespace xla::sim
