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

# Lambda packaging variables
LAMBDA_REPO_URL := https://github.com/aws-samples/serverless-pdf-chat.git
LAMBDA_REPO_BRANCH ?= main
WORK_DIR := $(PROJECTDIR)/work
LAMBDA_SRC_DIR := $(WORK_DIR)/backend/src
LAMBDA_FUNCTIONS := upload_trigger generate_presigned_url generate_embeddings get_document get_all_documents delete_document add_conversation generate_response
LAMBDA_DIST_DIR := $(BUILDDIR)/lambda
LAMBDA_PACKAGE_FILES := $(foreach func,$(LAMBDA_FUNCTIONS),$(LAMBDA_DIST_DIR)/$(func).zip)

# AWS variables for S3 upload
AWS_PROFILE ?= default
AWS_REGION ?= us-west-2
S3_BUCKET_NAME ?= $(shell kubectl get bucket.s3.aws.upbound.io -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

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

# Add lambda packaging to the charts target
charts:: package-lambdas

# Create work directory and clone/pull repository
$(WORK_DIR):
	mkdir -p $(WORK_DIR)

.PHONY: clone-upstream
clone-upstream: | $(WORK_DIR)
	@if [ -d "$(WORK_DIR)/.git" ]; then \
		echo "Upstream repository already exists, pulling latest changes..."; \
		cd $(WORK_DIR) && git pull; \
	else \
		echo "Cloning upstream repository..."; \
		git clone $(LAMBDA_REPO_URL) $(WORK_DIR) && \
		cd $(WORK_DIR) && git checkout $(LAMBDA_REPO_BRANCH); \
	fi

# Lambda packaging targets
$(LAMBDA_DIST_DIR):
	mkdir -p $(LAMBDA_DIST_DIR)

$(LAMBDA_DIST_DIR)/%.zip: clone-upstream | $(LAMBDA_DIST_DIR)
	@echo "Packaging Lambda function: $*"
	@mkdir -p $(LAMBDA_DIST_DIR)/$*-tmp
	@if [ -d "$(LAMBDA_SRC_DIR)/$*" ]; then \
		cd $(LAMBDA_SRC_DIR)/$* && \
		if [ -f "requirements.txt" ]; then \
			pip install -r requirements.txt -t $(LAMBDA_DIST_DIR)/$*-tmp --no-cache-dir; \
		fi && \
		cp -r *.py $(LAMBDA_DIST_DIR)/$*-tmp/ && \
		cd $(LAMBDA_DIST_DIR)/$*-tmp && \
		zip -r ../$(notdir $*).zip . && \
		cd $(CURDIR) && \
		rm -rf $(LAMBDA_DIST_DIR)/$*-tmp; \
	else \
		echo "Warning: Source directory for $* not found at $(LAMBDA_SRC_DIR)/$*"; \
		touch $(LAMBDA_DIST_DIR)/$*.zip; \
	fi

.PHONY: package-lambdas
package-lambdas: $(LAMBDA_PACKAGE_FILES)
	@echo "All Lambda functions packaged successfully"

.PHONY: upload-lambdas
upload-lambdas: package-lambdas
	@echo "Uploading Lambda packages to S3 bucket: $(S3_BUCKET_NAME)"
	@if [ -z "$(S3_BUCKET_NAME)" ]; then \
		echo "Error: S3 bucket name not found. Please specify S3_BUCKET_NAME."; \
		exit 1; \
	fi
	@for func in $(LAMBDA_FUNCTIONS); do \
		if [ -f "$(LAMBDA_DIST_DIR)/$$func.zip" ]; then \
			aws s3 cp $(LAMBDA_DIST_DIR)/$$func.zip s3://$(S3_BUCKET_NAME)/lambda/$$func.zip --profile $(AWS_PROFILE) --region $(AWS_REGION); \
			echo "Uploaded $$func.zip to s3://$(S3_BUCKET_NAME)/lambda/$$func.zip"; \
		else \
			echo "Warning: Package for $$func not found"; \
		fi \
	done

.PHONY: clean-lambdas
clean-lambdas:
	rm -rf $(LAMBDA_DIST_DIR)

.PHONY: clean-work
clean-work:
	rm -rf $(WORK_DIR)

.PHONY: clean
clean: clean-lambdas
	rm -rf $(BUILDDIR)

.PHONY: clean-all
clean-all: clean clean-work

# Convenience target for the complete Lambda workflow
.PHONY: lambdas
lambdas: clone-upstream package-lambdas upload-lambdas
	@echo "Lambda workflow completed: cloned repo, packaged functions, and uploaded to S3"

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
