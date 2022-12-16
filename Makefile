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

build: bin/linuxkit pkg

.PHONY: alpine
alpine:
	$(call PROMPT,$@)
	docker-compose exec builder make -C tools/alpine build

PKG=\
	ca-certificates \
	containerd \
	init \
	runc \
	sysctl

.PHONY: pkg $(addprefix pkg-,$(PKG))
pkg: $(addprefix pkg-,$(PKG))

VERSION=$(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null || git rev-parse --short HEAD)
HASH=$(shell git rev-parse --short HEAD)

# FORCE=-force -builder-restart
$(addprefix pkg-,$(PKG)): pkg-%: 
	$(call PROMPT,$@)
	docker-compose exec builder make -C pkg build OPTIONS="-platforms=linux/amd64 -docker -org=boyvinall/linuxkit -hash=$(VERSION) $(FORCE)" DIRS="$*"

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
	docker-compose exec builder make -C src/cmd/linuxkit local-build install PREFIX=/build/ GIT_COMMIT=$(HASH) VERSION=$(VERSION) BUILD_FLAGS=-buildvcs=false

.PHONY: clean
clean: stop
	rm -rf bin