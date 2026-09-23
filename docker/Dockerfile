FROM ubuntu:24.04@sha256:008173c23f95b170204355c12626cb5a965d779a7e1283b09e9cffbb1bf33ca3

# This image supplies build tools, not the XLA source or compiled plugin.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        patch \
        python3 \
        python3-venv \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY .bazelversion docker/bazel.sha256 /tmp/bazel-install/
RUN cd /tmp/bazel-install \
    && bazel_version="$(cat .bazelversion)" \
    && curl --fail --location --retry 3 \
        "https://releases.bazel.build/${bazel_version}/release/bazel-${bazel_version}-linux-x86_64" \
        --output "bazel-${bazel_version}-linux-x86_64" \
    && sha256sum --check bazel.sha256 \
    && install -m 0755 "bazel-${bazel_version}-linux-x86_64" /usr/local/bin/bazel \
    && rm -rf /tmp/bazel-install

# Match the invoking Linux user's ownership for bind-mounted source and caches.
ARG BUILD_UID=1000
ARG BUILD_GID=1000
RUN if ! getent group "${BUILD_GID}" >/dev/null; then groupadd --gid "${BUILD_GID}" builder; fi \
    && useradd --non-unique --uid "${BUILD_UID}" --gid "${BUILD_GID}" --create-home builder
USER builder
WORKDIR /workspace
CMD ["bash"]
