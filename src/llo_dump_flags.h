#ifndef SIM_PJRT_LLO_DUMP_FLAGS_H_
#define SIM_PJRT_LLO_DUMP_FLAGS_H_

#include <sstream>
#include <string>

namespace xla::sim {

// libtpu consumes whitespace-separated flags. Keep explicit user selection,
// including an empty regex, instead of overriding it with the compact default.
inline std::string DefaultLloDumpPassFilter(const std::string& flags) {
  const std::string name = "--xla_jf_dump_llo_pass_label_regex";
  std::istringstream tokens(flags);
  for (std::string token; tokens >> token;) {
    if (token == name || token.compare(0, name.size() + 1, name + "=") == 0)
      return "";
  }
  return " --xla_jf_dump_llo_pass_label_regex="
         "^(final_bundles|assembly-pre-overlay|deduplication-map)$";
}

}  // namespace xla::sim

#endif  // SIM_PJRT_LLO_DUMP_FLAGS_H_
