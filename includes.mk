ifndef COREOS_NUM_INSTANCES
  COREOS_NUM_INSTANCES = 1
endif

define echo_cyan
  @echo "\033[0;36m$(subst ",,$(1))\033[0m"
endef

define echo_yellow
  @echo "\033[0;33m$(subst ",,$(1))\033[0m"
endef

ifdef DOCKER_REGISTRY
  REPOSITORY = $(DOCKER_REGISTRY)
else
  REPOSITORY = $(MY_DOCKER_REGISTRY)/
endif
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
DOCKER_HOST = $(shell echo $$DOCKER_HOST)
REGISTRY = $(shell echo $$DEV_REGISTRY)
GIT_SHA = $(shell git rev-parse --short HEAD)
ifndef BUILD_TAG
  BUILD_TAG = git-$(GIT_SHA)
endif

IMAGE_PREFIX := $(REPOSITORY)

check-docker:
	@if [ -z $$(which docker) ]; then \
	  echo "Missing \`docker\` client which is required for development"; \
	  exit 2; \
	fi

check-registry:
	@if [ -z "$$DOCKER_REGISTRY" ]; then \
	  echo "DOCKER_REGISTRY is not exported, try:  make dev-environment"; \
	exit 2; \
	fi

check-awk:
	@if [ -z "$$(which awk)" ]; then \
	  echo "awk is not installed, try:  sudo apt-get install gawk"; \
	exit 2; \
	fi
