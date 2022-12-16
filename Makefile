.PHONY: all build
all: build

build: bin/linuxkit
	docker exec -ti linuxkit-cli-builder make -C tools/alpine build

PKG=\
	ca-certificates \
	containerd \
	init \
	runc \
	sysctl

# FORCE=-force
$(addprefix pkg-,$(PKG)): pkg-%: 
	docker exec -ti linuxkit-cli-builder make -C pkg build OPTIONS="-platforms=linux/amd64 -docker -builder-restart -org=boyvinall/linuxkit $(FORCE)" DIRS="$*"

.PHONY: start
start:
	docker-compose up -d --remove-orphans
	# docker exec linuxkit-builder apk add make docker

.PHONY: stop
stop:
	docker-compose down -v --remove-orphans

.PHONY: bin/linuxkit # always build
bin/linuxkit: start
	docker exec -ti linuxkit-cli-builder make -C src/cmd/linuxkit local-build install PREFIX=/build/
