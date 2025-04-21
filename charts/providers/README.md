# AWS Crossplane Providers Helm Chart

This Helm chart installs AWS Crossplane providers for the Serverless PDF Chat application.

## Overview

The chart sets up the following AWS Crossplane providers:

- AWS Family
- IAM
- S3
- DynamoDB
- Lambda
- SQS
- API Gateway v2
- Cognito IDP

It also installs the Kubernetes provider.

## Prerequisites

- Kubernetes cluster with Crossplane installed
- Helm 3.0+

## Installation

```bash
helm install providers ./charts/providers
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.images.registry` | Global registry for all images (overrides individual registry settings) | `""` |
| `global.images.pullSecrets` | Global list of image pull secret names for all images | `[]` |
| `commonLabels` | Common labels to add to all resources | `{}` |
| `commonAnnotations` | Common annotations to add to all resources | `{}` |
| `serviceAccount.create` | Whether to create a ServiceAccount | `true` |
| `serviceAccount.name` | Name of the ServiceAccount to use (if not created) | `""` |
| `aws.imagePullSecrets` | Image pull secrets for AWS providers | `[]` |
| `aws.deploymentRuntimeConfig.resources.limits.cpu` | CPU limit for provider controllers | `500m` |
| `aws.deploymentRuntimeConfig.resources.limits.memory` | Memory limit for provider controllers | `512Mi` |
| `aws.deploymentRuntimeConfig.resources.requests.cpu` | CPU request for provider controllers | `100m` |
| `aws.deploymentRuntimeConfig.resources.requests.memory` | Memory request for provider controllers | `256Mi` |
| `aws.providers.registry` | Registry for all providers (overridden by global registry if set) | `xpkg.upbound.io/upbound` |
| `aws.providers.<provider>.package` | Package name for the provider | Varies by provider |
| `aws.providers.<provider>.version` | Version of the provider | `v1.21.1` |
| `kubernetes.imagePullSecrets` | Image pull secrets for Kubernetes provider | `[]` |
| `kubernetes.provider.version` | Version of the Kubernetes provider | `v0.17.2` |
| `kubernetes.provider.registry` | Registry for the Kubernetes provider (overridden by global registry if set) | `xpkg.upbound.io/upbound` |
| `jobs.imagePullSecrets` | Image pull secrets for jobs | `[]` |
| `jobs.waitReadyJob.image.registry` | Registry for wait-ready job image (overridden by global registry if set) | `docker.io` |
| `jobs.waitReadyJob.image.repository` | Repository for wait-ready job image | `bitnami/kubectl` |
| `jobs.waitReadyJob.image.tag` | Tag for wait-ready job image | `latest` |
| `jobs.waitReadyJob.image.pullPolicy` | Pull policy for wait-ready job image | `IfNotPresent` |
| `jobs.waitReadyJob.resources.limits.cpu` | CPU limit for wait-ready job | `200m` |
| `jobs.waitReadyJob.resources.limits.memory` | Memory limit for wait-ready job | `256Mi` |
| `jobs.waitReadyJob.resources.requests.cpu` | CPU request for wait-ready job | `100m` |
| `jobs.waitReadyJob.resources.requests.memory` | Memory request for wait-ready job | `128Mi` |
| `jobs.waitReadyJob.securityContext.runAsNonRoot` | Run wait-ready job as non-root | `true` |
| `jobs.waitReadyJob.securityContext.runAsUser` | User ID to run wait-ready job | `1001` |
| `jobs.waitReadyJob.securityContext.runAsGroup` | Group ID to run wait-ready job | `1001` |

### Registry and Pull Secrets Configuration Examples

To use a custom registry for all images:

```yaml
global:
  images:
    registry: custom.registry.example.com
```

To override specific registries while using global registry for others:

```yaml
global:
  images:
    registry: custom.registry.example.com
aws:
  providers:
    registry: specific.registry.example.com
```

To configure image pull secrets for all providers:

```yaml
global:
  images:
    pullSecrets:
    - global-registry-secret
```

To configure image pull secrets for specific provider types:

```yaml
global:
  images:
    pullSecrets:
    - global-registry-secret
aws:
  providers:
    pullSecrets:
    - aws-registry-secret
kubernetes:
  imagePullSecrets:
  - name: k8s-registry-secret
jobs:
  imagePullSecrets:
  - name: jobs-registry-secret
```

## License

This chart is licensed under the MIT License.
