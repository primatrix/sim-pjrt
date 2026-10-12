#include "src/llo_dump_flags.h"

#include <iostream>
#include <string>

int main() {
  const std::string flag = "--xla_jf_dump_llo_pass_label_regex";
  const std::string compact = " " + flag +
      "=^(final_bundles|assembly-pre-overlay|deduplication-map)$";
  struct Case { std::string input; std::string expected; };
  const Case cases[] = {
      {"", compact},
      {"--xla_mosaic_enable_llo_source_annotations=true", compact},
      {flag + "=.*", ""},
      {"--other=1\n\t" + flag + "=^(final_bundles|critical-path)$ --last=2", ""},
      {flag + "=", ""},
      {flag + " .*", ""},
      {flag + "_other=.*", compact},
      {"--other=" + flag + "=.*", compact},
      {"prefix" + flag + "=.*", compact},
  };
  for (const auto& test : cases) {
    if (xla::sim::DefaultLloDumpPassFilter(test.input) != test.expected) {
      std::cerr << "Unexpected dump filter for: " << test.input << '\n';
      return 1;
    }
  }
  return 0;
}
