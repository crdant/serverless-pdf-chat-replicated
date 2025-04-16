# AWS Crossplane Providers Helm Chart

This Helm chart installs AWS Crossplane providers for the Serverless PDF Chat application.

## Overview

The chart sets up the following AWS Crossplane providers:

- IAM
- S3
- DynamoDB
- Lambda
- SQS
- API Gateway v2
- Cognito IDP
- Bedrock
- CloudFront
- Secrets Manager

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
| `aws.defaultDeploymentConfig.resources.limits.cpu` | CPU limit for provider controllers | `500m` |
| `aws.defaultDeploymentConfig.resources.limits.memory` | Memory limit for provider controllers | `512Mi` |
| `aws.defaultDeploymentConfig.resources.requests.cpu` | CPU request for provider controllers | `100m` |
| `aws.defaultDeploymentConfig.resources.requests.memory` | Memory request for provider controllers | `256Mi` |
| `aws.providers.registry` | Registry for all providers | `xpkg.upbound.io/upbound` |
| `aws.providers.<provider>.package` | Package name for the provider | Varies by provider |
| `aws.providers.<provider>.version` | Version of the provider | `v1.21.1` |
| `kubernetes.provider.version` | Version of the Kubernetes provider | `v0.17.2` |
| `kubernetes.provider.registry` | Registry for the Kubernetes provider | `xpkg.upbound.io/upbound` |

## License

This chart is licensed under the MIT License.
