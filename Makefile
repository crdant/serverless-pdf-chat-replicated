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
DOCKER_REGISTRY ?= ghcr.io
DOCKER_REPO ?= crdant/serverless-pdf-chat
DOCKER_TAG ?= latest
LAMBDA_FUNCTIONS := upload-trigger generate-presigned-url generate-embeddings get-document get-all-documents delete-document add-conversation generate-response
DOCKER_IMAGES := $(addprefix docker-build-,$(LAMBDA_FUNCTIONS))
DOCKER_PUSHES := $(addprefix docker-push-,$(LAMBDA_FUNCTIONS))

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

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Docker build targets
.PHONY: docker-build-%
docker-build-%:
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$*:$(DOCKER_TAG) -f docker/$*/Dockerfile .

.PHONY: docker-push-%
docker-push-%: docker-build-%
	docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$*:$(DOCKER_TAG)

.PHONY: docker-build
docker-build: $(DOCKER_IMAGES)

.PHONY: docker-push
docker-push: $(DOCKER_PUSHES)

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
