FROM node:20-bookworm-slim AS node

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=coder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    lsof \
    socat \
    sudo \
    docker.io \
    docker-compose-v2 \
  && rm -rf /var/lib/apt/lists/*

# Node.js LTS (Node 20) without external HTTPS downloads
COPY --from=node /usr/local/ /usr/local/

RUN useradd --groups sudo --create-home --shell /bin/bash ${USER} \
  && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
  && chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
WORKDIR /home/${USER}
