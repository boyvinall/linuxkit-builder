.PHONY: all build
all: build

ifndef PROMPT
define PROMPT
	@echo
	@echo "**********************************************************"
	@echo "*"
	@echo "*   $(1)"
	@echo "*"
	@echo "**********************************************************"
	@echo
endef
endif

# currently it's mostly pointless building alpine because the pkg images reference a specific hash
# build: bin/linuxkit alpine pkg

build: bin/linuxkit pkg image

.PHONY: alpine
alpine:
	$(call PROMPT,$@)
	docker-compose exec builder make -C tools/alpine build

PKG=\
	ca-certificates \
	containerd \
	dhcpcd \
	firmware \
	format \
	getty \
	init \
	metadata \
	modprobe \
	mount \
	node_exporter \
	openntpd \
	rngd \
	runc \
	sshd \
	sysctl

.PHONY: pkg $(addprefix pkg-,$(PKG))
pkg: $(addprefix pkg-,$(PKG))

VERSION=$(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null || git rev-parse --short HEAD)
HASH=$(shell git rev-parse --short HEAD)

DOCKER_ORG=boyvinall/linuxkit
DOCKER_PKG=$(addprefix $(DOCKER_ORG)/,$(PKG))

# FORCE=-force -builder-restart
$(addprefix pkg-,$(PKG)): pkg-%: 
	$(call PROMPT,$@)
	docker-compose exec builder make -C pkg build OPTIONS="-platforms=linux/amd64 -docker -org=$(DOCKER_ORG) -hash=latest $(FORCE)" DIRS="$*"

.PHONY: start
start:
	$(call PROMPT,$@)
	docker-compose up -d --build

.PHONY: stop
stop:
	$(call PROMPT,$@)
	docker-compose down -v --remove-orphans
	docker rm -f linuxkit-builder

.PHONY: bin/linuxkit # always build
bin/linuxkit: start
	$(call PROMPT,$@)
	mkdir -p bin
	docker-compose exec builder make -C src/cmd/linuxkit local-build install PREFIX=/linuxkit-builder/ GIT_COMMIT=$(HASH) VERSION=$(VERSION) BUILD_FLAGS=-buildvcs=false

.PHONY: clean
clean: stop
	rm -rf bin

.PHONY: image
image:
	$(call PROMPT,$@)
	which yq > /dev/null && docker pull $$(yq .kernel.image linuxkit.yml)
	docker-compose exec -w /linuxkit-builder builder linuxkit build -format qcow2-bios -docker -dir bin linuxkit.yml

.PHONY: run
run:
	$(call PROMPT,$@)
	docker-compose exec -w /linuxkit-builder builder linuxkit run qemu -publish 80 bin/linuxkit.qcow2

DOCKER_PUSH_PKG=$(addprefix docker-push-,$(DOCKER_PKG))

.PHONY: docker-push $(DOCKER_PUSH_PKG)
docker-push: $(DOCKER_PUSH_PKG)

$(DOCKER_PUSH_PKG): docker-push-%:
	$(call PROMPT,docker-push $*)
	docker push $*:latest
