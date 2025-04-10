PROJECTDIR := $(shell pwd)

# Set default parallelism
MAKEFLAGS += -j$(shell nproc)

CHARTDIR    := $(PROJECTDIR)/charts
CHARTS      := $(shell find $(CHARTDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

MANIFESTDIR := $(PROJECTDIR)/replicated
MANIFESTS   := $(shell find $(MANIFESTDIR) -name '*.yaml' -o -name '*.yml')

# Cache chart versions
define cache-chart-version
$(eval CHART_$(1)_VERSION := $(shell yq .version $(CHARTDIR)/$(1)/Chart.yaml))
endef
$(foreach chart,$(CHARTS),$(eval $(call cache-chart-version,$(chart))))

VERSION     ?= $(CHART_cloud-resources_VERSION)
CHANNEL     := $(shell git branch --show-current)
ifeq ($(CHANNEL), main)
	CHANNEL=Unstable
endif

BUILDDIR      := $(PROJECTDIR)/build
RELEASE_FILES := 

# Docker variables
DOCKER_CMD ?= docker  # Default to docker, can be overridden with DOCKER_CMD=nerdctl
AWS_REGION ?= us-west-2
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
DOCKER_REGISTRY ?= $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
DOCKER_REPO ?= serverless-pdf-chat

# Cache Git information
GIT_REMOTE := $(shell git remote get-url origin)
GIT_HTTPS_URL := $(shell echo "$(GIT_REMOTE)" | sed -E 's|git@([^:]+):|https://\1/|g' | sed -E 's|\.git$$||')
GIT_REVISION := $(shell git rev-parse HEAD)

# Use the chart appVersion as the default Docker tag
APP_VERSION := $(shell yq .appVersion $(CHARTDIR)/serverless-pdf-chat/Chart.yaml)
DOCKER_TAG ?= $(APP_VERSION)
# Extract major and major.minor versions for additional tags
MAJOR_VERSION := $(shell echo $(DOCKER_TAG) | cut -d. -f1)
MINOR_VERSION := $(shell echo $(DOCKER_TAG) | cut -d. -f1,2)
DOCKERDIR := $(PROJECTDIR)/docker
DOCKER_IMAGES := $(shell find $(DOCKERDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Group all .PHONY targets
.PHONY: charts manifests images ecr-login clean lint release $(addprefix docker-build-,$(DOCKER_IMAGES)) $(addprefix docker-push-,$(DOCKER_IMAGES)) $(addprefix create-ecr-repo-,$(DOCKER_IMAGES))

# ECR login target
ecr-login:
	@echo "Logging in to Amazon ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | $(DOCKER_CMD) login --username AWS --password-stdin $(DOCKER_REGISTRY)

# ECR repository creation target
create-ecr-repo-%:
	@echo "Creating ECR repository for $*..."
	aws ecr describe-repositories --repository-names $(DOCKER_REPO)/$* --region $(AWS_REGION) --no-cli-pager || \
	aws ecr create-repository --repository-name $(DOCKER_REPO)/$* --region $(AWS_REGION) --no-cli-pager

define make-manifest-target
$(BUILDDIR)/$(notdir $1): $1 | $$(BUILDDIR)
	cp $1 $$(BUILDDIR)/$$(notdir $1)
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$(notdir $1)
manifests:: $(BUILDDIR)/$(notdir $1)
endef
$(foreach element,$(MANIFESTS),$(eval $(call make-manifest-target,$(element))))

define make-chart-target
$(BUILDDIR)/$1-$(CHART_$1_VERSION).tgz : $(shell find $(CHARTDIR)/$1 -name '*.yaml' -o -name '*.yml' -o -name "*.tpl" -o -name "NOTES.txt" -o -name "values.schema.json") | $$(BUILDDIR)
	helm package -u $(CHARTDIR)/$1 -d $(BUILDDIR)/
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$1-$(CHART_$1_VERSION).tgz
charts:: $(BUILDDIR)/$1-$(CHART_$1_VERSION).tgz
endef
$(foreach element,$(CHARTS),$(eval $(call make-chart-target,$(element))))

# Define Docker build and push targets dynamically
define make-docker-target
docker-build-$1: create-ecr-repo-$1
	@echo "Building Docker image: $1 with tag $(DOCKER_TAG)"
	$(DOCKER_CMD) build \
		--label org.opencontainers.image.source="$(GIT_HTTPS_URL)" \
		--label org.opencontainers.image.revision="$(GIT_REVISION)" \
		--label org.opencontainers.image.version="$(DOCKER_TAG)" \
		--label org.opencontainers.image.title="$1" \
		--label org.opencontainers.image.description="Lambda function for serverless-pdf-chat" \
		-t $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(DOCKER_TAG) \
		-t $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(MINOR_VERSION) \
		-t $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(MAJOR_VERSION) \
		-f $(DOCKERDIR)/$1/Dockerfile $(DOCKERDIR)/$1
	@echo "Tagged image with $(DOCKER_TAG), $(MINOR_VERSION), and $(MAJOR_VERSION)"

docker-push-$1: docker-build-$1 ecr-login
	@echo "Pushing Docker image: $1 with tags $(DOCKER_TAG), $(MINOR_VERSION), and $(MAJOR_VERSION)"
	$(DOCKER_CMD) push $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(DOCKER_TAG)
	$(DOCKER_CMD) push $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(MINOR_VERSION)
	$(DOCKER_CMD) push $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$1:$(MAJOR_VERSION)

# Add each image to the images target dependencies
images:: docker-push-$1
endef
$(foreach image,$(DOCKER_IMAGES),$(eval $(call make-docker-target,$(image))))

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)

debug:
	@echo "DOCKER_IMAGES = $(DOCKER_IMAGES)"
	@echo "PHONY targets for create-ecr-repo = $(addprefix create-ecr-repo-,$(DOCKER_IMAGES))"
	@echo "DOCKERDIR = $(DOCKERDIR)"
	@echo "Find command output:"
	@find $(DOCKERDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;

lint: $(RELEASE_FILES) 
	replicated release lint --yaml-dir $(BUILDDIR)

release: $(RELEASE_FILES) lint
	replicated release create \
	 	--app ${REPLICATED_APP} \
		--version $(VERSION) \
		--yaml-dir $(BUILDDIR) \
		--ensure-channel \
		--promote $(CHANNEL)
