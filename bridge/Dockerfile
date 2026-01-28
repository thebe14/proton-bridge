# The build image could be golang, but it currently does not support riscv64. Only debian:sid does, at the time of writing.
FROM debian:sid-slim AS build

ARG VERSION

# Install dependencies
RUN apt-get update && apt-get install -y golang build-essential libsecret-1-dev

# Build
ADD https://github.com/ProtonMail/proton-bridge.git#v${VERSION} /build/
WORKDIR /build/
RUN make build-nogui vault-editor

# Assemble image
FROM debian:sid-slim
LABEL maintainer="Levente F. <thebe14@proton.me>"

EXPOSE 25/tcp
EXPOSE 143/tcp

# Install dependencies and protonmail bridge
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat pass libsecret-1-0 ca-certificates jq inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Copy bash scripts
COPY gpgparams entrypoint.sh extract-cert.sh /protonmail/

RUN chmod a+x /protonmail/extract-cert.sh

# Copy protonmail
COPY --from=build /build/bridge /protonmail/
COPY --from=build /build/proton-bridge /protonmail/
COPY --from=build /build/vault-editor /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]