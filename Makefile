PROJECTDIR := $(shell pwd)

CHARTDIR    := $(PROJECTDIR)/charts
CHARTS      := $(shell find $(CHARTDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

MANIFESTDIR := $(PROJECTDIR)/replicated
MANIFESTS   := $(shell find $(MANIFESTDIR) -name '*.yaml' -o -name '*.yml')

VERSION     ?= $(shell yq .version $(CHARTDIR)/cloud-resources/Chart.yaml)
CHANNEL     := $(shell git branch --show-current)
ifeq ($(CHANNEL), main)
	CHANNEL=Unstable
endif

BUILDDIR      := $(PROJECTDIR)/build
RELEASE_FILES := 

# Docker variables
DOCKER_CMD ?= docker  # Default to docker, can be overridden with DOCKER_CMD=nerdctl
DOCKER_REGISTRY ?= ghcr.io
DOCKER_REPO ?= crdant/serverless-pdf-chat
# Use the chart appVersion as the default Docker tag
APP_VERSION := $(shell yq .appVersion $(CHARTDIR)/serverless-pdf-chat/Chart.yaml)
DOCKER_TAG ?= $(APP_VERSION)
DOCKERDIR := $(PROJECTDIR)/docker
DOCKER_IMAGES := $(shell find $(DOCKERDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

define make-manifest-target
$(BUILDDIR)/$(notdir $1): $1 | $$(BUILDDIR)
	cp $1 $$(BUILDDIR)/$$(notdir $1)
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$(notdir $1)
manifests:: $(BUILDDIR)/$(notdir $1)
endef
$(foreach element,$(MANIFESTS),$(eval $(call make-manifest-target,$(element))))

define make-chart-target
$(eval VER := $(shell yq .version $(CHARTDIR)/$1/Chart.yaml))
$(BUILDDIR)/$1-$(VER).tgz : $(shell find $(CHARTDIR)/$1 -name '*.yaml' -o -name '*.yml' -o -name "*.tpl" -o -name "NOTES.txt" -o -name "values.schema.json") | $$(BUILDDIR)
	helm package -u $(CHARTDIR)/$1 -d $(BUILDDIR)/
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$1-$(VER).tgz
charts:: $(BUILDDIR)/$1-$(VER).tgz
endef
$(foreach element,$(CHARTS),$(eval $(call make-chart-target,$(element))))

# Define Docker build and push targets dynamically
define make-docker-target
.PHONY: docker-build-$1
docker-build-$1:
	@echo "Building Docker image: $1 with tag $(DOCKER_TAG)"
	$(DOCKER_CMD) build -t $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(DOCKER_TAG) -f $(DOCKERDIR)/$1/Dockerfile $(DOCKERDIR)/$1

.PHONY: docker-push-$1
docker-push-$1: docker-build-$1
	@echo "Pushing Docker image: $1 with tag $(DOCKER_TAG)"
	$(DOCKER_CMD) push $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(DOCKER_TAG)

# Add each image to the images target dependencies
images:: docker-push-$1
endef
$(foreach image,$(DOCKER_IMAGES),$(eval $(call make-docker-target,$(image))))

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)

.PHONY: lint
lint: $(RELEASE_FILES) 
	replicated release lint --yaml-dir $(BUILDDIR)

.PHONY: release
release: $(RELEASE_FILES) lint
	replicated release create \
	 	--app ${REPLICATED_APP} \
		--version $(VERSION) \
		--yaml-dir $(BUILDDIR) \
		--ensure-channel \
		--promote $(CHANNEL)
