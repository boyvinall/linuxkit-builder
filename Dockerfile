FROM golang:1.19.3

RUN \
    apt-get update && \
    apt-get install -y qemu-kvm tini && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.17.tgz | tar -xzf - -O docker/docker > /usr/local/bin/docker && \
    curl -sL https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker /usr/local/bin/docker-compose

# some utils, not needed for the build
RUN \
    apt-get update && \
    apt-get install -y net-tools && \
    rm -rf /var/lib/apt/lists/* && \
    go install github.com/mikefarah/yq/v4@latest