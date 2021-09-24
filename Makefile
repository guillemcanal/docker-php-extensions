.DEFAULT_GOAL := build

DOCKER_REPO?=$(USER)

PHP_VERSIONS?=\
	8.1.0RC2-alpine3.14\
	8.0.10-alpine3.14\
	7.4.23-alpine3.14\
	7.3.30-alpine3.14

PHP_TOOLS=\
	composer\
	symfony\
	psysh

DOCKER_BUILD=docker build \
	--build-arg PHP_VERSION=$(PHP_VERSION) \
	--build-arg PHP_DISTRO=$(PHP_DISTRO) \
	--build-arg DOCKER_REPO=$(DOCKER_REPO) \
	--build-arg PHP_EXT=$(PHP_EXT) \
	-t $(DOCKER_REPO)/php-extra:$(subst @,,$*) \
	-f $(DOCKERFILE) \
	.

include ./make/php_exts.mk

ifeq ($(or $(MAKECMDGOALS),$(.DEFAULT_GOAL)),build)
	BUILD_MATRIX :=$(shell ./scripts/build-pecl-extensions-matrix "$(PHP_VERSIONS)" "$(PHP_EXTS)")
	IMAGES_BUILD := $(PHP_VERSIONS:%=.build/%-build)
	IMAGES_EXT := $(BUILD_MATRIX:%=.build/%)
	PHP_VERSION = $(word 1,$(subst -, ,$*))
	PHP_DISTRO = $(word 2,$(subst -, ,$*))
	PHP_EXT = $(word 4,$(subst -, ,$*))
endif

.PHONY: build
build: update $(IMAGES_EXT) utilities

.PHONY: update
update:
	@mkdir -p ./scripts/data
	@curl -sL https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/data/special-requirements > ./scripts/data/special-requirements
	@curl -sL https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/data/supported-extensions > ./scripts/data/supported-extensions
	@curl -sL https://raw.githubusercontent.com/mlocati/pecl-info/main/public/data/summary.min.json > ./scripts/data/pecl-extensions.json
	@cat ./scripts/data/supported-extensions | sed $$'1s/^/PHP_EXTS?=\\n/' | awk '{print $$1"\\"}' > ./make/php_exts.mk

$(IMAGES_BUILD): DOCKERFILE=Dockerfile.build
$(IMAGES_BUILD): .build/%: Dockerfile.build
	@echo "building $*"
	@$(DOCKER_BUILD)
	@mkdir -p .build && touch "$@"

$(IMAGES_EXT): $(IMAGES_BUILD)
$(IMAGES_EXT): DOCKERFILE=Dockerfile.ext
$(IMAGES_EXT): .build/%: Dockerfile.ext
	@echo "building $*"
	@$(DOCKER_BUILD)
	@mkdir -p .build && touch "$@"

IMAGES_UTILITIES=$(PHP_TOOLS:%=.build/%)
$(IMAGES_UTILITIES): .build/%: ./utilities/Dockerfile.%
	@DOCKER_BUILDKIT=1 docker build -t $(DOCKER_REPO)/php:$* -f ./utilities/Dockerfile.$* ./utilities
	@mkdir -p .build && touch "$@"

.PHONY: utilities
utilities: $(IMAGES_UTILITIES)
