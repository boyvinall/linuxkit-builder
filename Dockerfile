FROM golang:1.19.3

RUN \
    apt-get update && \
    apt-get remove -y python python2.7 python-minimal python2.7-minimal && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.17.tgz | tar -xzf - -O docker/docker > /usr/local/bin/docker && \
    curl -sL https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker /usr/local/bin/docker-compose
