load("@rules_python//python:py_library.bzl", "py_library")
load("@rules_python//python:py_test.bzl", "py_test")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@xla//xla:xla.default.bzl", "xla_cc_binary", "xla_cc_test")

package(default_visibility = ["//visibility:public"])

# Load the canonical XSpace schema in Python without TensorFlow or a checked-in
# generated protobuf module tied to a particular protobuf runtime version.
genrule(
    name = "xplane_descriptor",
    srcs = ["@tsl//tsl/profiler/protobuf:xplane.proto"],
    outs = ["xplane.descriptor.pb"],
    cmd = "$(execpath @com_google_protobuf//:protoc) " +
          "--proto_path=$$(dirname $(location @tsl//tsl/profiler/protobuf:xplane.proto)) " +
          "--descriptor_set_out=$@ $(location @tsl//tsl/profiler/protobuf:xplane.proto)",
    tools = ["@com_google_protobuf//:protoc"],
)

cc_library(
    name = "profiler",
    srcs = ["profiler.cc"],
    hdrs = ["profiler.h"],
    deps = [
        "@xla//xla:future",
        "@xla//xla/pjrt/c:pjrt_c_api_profiler_extension_hdrs",
        "@xla//xla/tsl/profiler/utils:xplane_builder",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/strings",
        "@tsl//tsl/platform:env",
        "@tsl//tsl/profiler/protobuf:xplane_proto_cc",
    ],
)

xla_cc_test(
    name = "profiler_test",
    srcs = ["profiler_test.cc"],
    deps = [
        ":profiler",
        "@xla//xla:future",
        "@com_google_absl//absl/status",
        "@com_google_googletest//:gtest_main",
        "@com_google_protobuf//:protobuf",
        "@tsl//tsl/platform:status_matchers",
        "@tsl//tsl/profiler/protobuf:xplane_proto_cc",
    ],
)

xla_cc_test(
    name = "hlo_model_test",
    srcs = ["hlo_model_test.cc"],
    deps = [
        ":hlo_model",
        ":program_snapshot",
        ":runtime",
        "@xla//xla/hlo/parser:hlo_parser",
        "@xla//xla/hlo/ir:hlo",
        "@com_google_absl//absl/status",
        "@tsl//tsl/platform:status_matchers",
        "@com_google_googletest//:gtest_main",
    ],
)

xla_cc_test(
    name = "instrumentation_test",
    srcs = ["instrumentation_test.cc", "instrumentation.cc", "instrumentation.h"],
    deps = [
        ":hlo_model",
        ":virtual_storage",
        ":runtime",
        ":profiler",
        "@xla//xla/pjrt/c:pjrt_c_api_cpu_internal",
        "@xla//xla/pjrt/c:pjrt_c_api_status_utils",
        "@xla//xla/pjrt/c:pjrt_c_api_wrapper_impl",
        "@com_google_absl//absl/log",
        "@com_google_absl//absl/status",
        "@com_google_googletest//:gtest_main",
        "@tsl//tsl/platform:env",
        "@tsl//tsl/platform:status_matchers",
    ],
)

cc_library(
    name = "hlo_model",
    srcs = ["hlo_model.cc"],
    hdrs = ["hlo_model.h"],
    deps = [
        ":hlo_utils",
        "@xla//xla:literal_util",
        "@xla//xla:shape_util",
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/service:hlo_cost_analysis",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/strings",
        "@com_google_absl//absl/status:status_macros",
    ],
)

xla_cc_binary(
    name = "pjrt_sim_plugin.so",
    srcs = ["plugin.cc", "instrumentation.cc", "instrumentation.h", "profiler_api.cc"],
    linkshared = True,
    deps = [
        "@tsl//tsl/profiler/protobuf:xplane_proto_cc",
        ":hlo_model",
        ":program_snapshot",
        ":virtual_storage",
        ":runtime",
        ":profiler",
        ":partitioning",
        "@xla//xla/backends/profiler/plugin:profiler_error",
        "@xla//xla/hlo/builder:xla_computation",
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/pjrt:mlir_to_hlo",
        "@xla//xla/pjrt/c:pjrt_c_api_cpu_internal",
        "@xla//xla/pjrt/c:pjrt_c_api_helpers",
        "@xla//xla/pjrt/c:pjrt_c_api_hdrs",
        "@xla//xla/pjrt/c:pjrt_c_api_layouts_extension_hdrs",
        "@xla//xla/pjrt/c:pjrt_c_api_status_utils",
        "@xla//xla/pjrt/c:pjrt_c_api_wrapper_impl",
        "@xla//xla/pjrt/plugin/xla_cpu:cpu_client_options",
        "@xla//xla/pjrt/plugin/xla_cpu:xla_cpu_pjrt_client",
        "@xla//xla/pjrt/proto:compile_options_proto_cc",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/log",
        "@com_google_absl//absl/strings:string_view",
        "@com_google_absl//absl/strings",
        "@llvm-project//mlir:IR",
        "@tsl//tsl/platform:env",
        "@tsl//tsl/profiler/protobuf:profiler_options_proto_cc",
        "@com_google_absl//absl/status:status_macros",
    ],
)

cc_library(
    name = "execution_plan",
    srcs = ["execution_plan.cc", "pallas_cost.cc"],
    hdrs = ["execution_plan.h", "pallas_cost.h"],
    deps = [
        ":hlo_utils",
        "@xla//xla:shape_util",
        "@xla//xla/hlo/ir:hlo",
        "@com_google_protobuf//:protobuf",
        "@com_google_absl//absl/strings",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/status:status_macros",
    ],
)

cc_library(
    name = "runtime",
    srcs = ["runtime.cc"],
    hdrs = ["runtime.h"],
    deps = [
        ":execution_plan",
        ":profiler",
        "@xla//xla:future",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/status:status_macros",
        "@com_google_absl//absl/strings",
        "@tsl//tsl/platform:env",
    ],
)

xla_cc_test(
    name = "runtime_test",
    srcs = ["runtime_test.cc"],
    deps = [
        ":runtime",
        ":execution_plan",
        "@xla//xla:future",
        "@com_google_absl//absl/status",
        "@com_google_googletest//:gtest_main",
        "@tsl//tsl/platform:status_matchers",
    ],
)

xla_cc_test(
    name = "execution_plan_test",
    srcs = ["execution_plan_test.cc"],
    deps = [
        ":execution_plan",
        "@xla//xla/hlo/parser:hlo_parser",
        "@com_google_googletest//:gtest_main",
        "@tsl//tsl/platform:status_matchers",
    ],
)

cc_library(
    name = "virtual_storage",
    srcs = ["virtual_storage.cc"],
    hdrs = ["virtual_storage.h"],
    deps = [
        "@xla//xla:literal_util",
        "@xla//xla:shape_util",
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/hlo/builder:xla_computation",
        "@xla//xla/pjrt:pjrt_client",
        "@xla//xla/pjrt/c:pjrt_c_api_helpers",
        "@xla//xla/pjrt/c:pjrt_c_api_status_utils",
        "@xla//xla/pjrt/c:pjrt_c_api_wrapper_impl",
        "@xla//xla/service:computation_layout",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/status:status_macros",
        "@com_google_absl//absl/strings",
    ],
)

xla_cc_test(
    name = "virtual_storage_test",
    srcs = ["virtual_storage_test.cc"],
    deps = [
        ":virtual_storage",
        "@xla//xla/hlo/parser:hlo_parser",
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/service:hlo_verifier",
        "@com_google_absl//absl/status",
        "@com_google_googletest//:gtest_main",
        "@tsl//tsl/platform:status_matchers",
    ],
)

cc_library(
    name = "partitioning",
    srcs = ["partitioning.cc"],
    hdrs = ["partitioning.h"],
    deps = [
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/pjrt:pjrt_client",
        "@xla//xla/hlo/transforms/simplifiers:conditional_canonicalizer",
        "@xla//xla/hlo/transforms/simplifiers:flatten_call_graph",
        "@xla//xla/hlo/transforms/simplifiers:zero_sized_hlo_elimination",
        "@xla//xla/service:call_inliner",
        "@xla//xla/service:control_dep_rewriter",
        "@xla//xla/service:sharding_propagation",
        "@xla//xla/service/spmd:stateful_rng_spmd_partitioner",
        "@xla//xla/service/spmd/shardy:shardy_xla_pass",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:status_macros",
    ],
)

cc_library(
    name = "hlo_utils",
    hdrs = ["hlo_utils.h"],
    deps = ["@xla//xla/hlo/ir:hlo"],
)

cc_library(
    name = "program_snapshot",
    srcs = ["program_snapshot.cc"],
    hdrs = ["program_snapshot.h"],
    deps = [
        ":execution_plan",
        "@xla//xla/hlo/ir:hlo",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/status:status_macros",
        "@com_google_absl//absl/strings",
        "@com_google_protobuf//:protobuf",
    ],
)

xla_cc_binary(
    name = "plan_export",
    srcs = ["plan_export.cc"],
    deps = [
        ":execution_plan",
        ":program_snapshot",
        "@xla//xla/hlo/ir:hlo",
        "@xla//xla/hlo/parser:hlo_parser",
        "@com_google_absl//absl/status",
        "@com_google_absl//absl/status:statusor",
        "@com_google_absl//absl/status:status_macros",
        "@com_google_absl//absl/strings",
        "@com_google_protobuf//:protobuf",
    ],
)

# Fast deterministic model tests run with Bazel's Python toolchain; no JAX needed.
py_library(
    name = "analysis_tools",
    imports = ["."],
    srcs = glob(["*.py"], exclude = ["*_test.py"]),
)

py_test(
    name = "virtual_clock_test",
    size = "small",
    srcs = ["virtual_clock_test.py"],
    deps = [":analysis_tools"],
)

py_test(
    name = "report_test",
    size = "small",
    srcs = ["report_test.py"],
    deps = [":analysis_tools"],
)

py_test(
    name = "profile_report_test",
    size = "small",
    srcs = ["profile_report_test.py"],
    deps = [":analysis_tools"],
)

test_suite(
    name = "python_tests",
    tests = [":virtual_clock_test", ":report_test", ":profile_report_test"],
)
