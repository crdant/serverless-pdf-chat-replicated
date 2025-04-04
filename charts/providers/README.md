# AWS Crossplane Providers Helm Chart

This Helm chart installs and configures AWS Crossplane providers for the Serverless PDF Chat application.

## Overview

The chart sets up the following AWS Crossplane providers:

- IAM
- S3
- DynamoDB
- Lambda
- SQS
- API Gateway
- Cognito
- Bedrock
- CloudFront
- Secrets Manager

## Prerequisites

- Kubernetes cluster with Crossplane installed
- Helm 3.0+

## Installation

```bash
helm install providers ./charts/providers \
  --set aws.region=us-east-1 \
  --set aws.authentication.method=secret \
  --set-string aws.authentication.secret.name=aws-credentials \
  --set-string aws.authentication.secret.namespace=crossplane-system
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `aws.region` | AWS region where resources will be provisioned | `us-east-1` |
| `aws.providerConfigName` | Name of the provider configuration | `default` |
| `aws.authentication.method` | Method to authenticate with AWS (secret, irsa, or ec2) | `secret` |
| `aws.authentication.secret.name` | Name of the secret containing AWS credentials | `aws-credentials` |
| `aws.authentication.secret.namespace` | Namespace where the secret is located | `crossplane-system` |
| `aws.authentication.secret.keys.accessKeyId` | Key for AWS access key ID | `aws_access_key_id` |
| `aws.authentication.secret.keys.secretAccessKey` | Key for AWS secret access key | `aws_secret_access_key` |
| `aws.providers.iam.version` | Version of the IAM provider | `v0.41.0` |
| `aws.providers.s3.version` | Version of the S3 provider | `v0.41.0` |
| `aws.providers.dynamodb.version` | Version of the DynamoDB provider | `v0.41.0` |
| `aws.providers.lambda.version` | Version of the Lambda provider | `v0.41.0` |
| `aws.providers.sqs.version` | Version of the SQS provider | `v0.41.0` |
| `aws.providers.apigateway.version` | Version of the API Gateway provider | `v0.41.0` |
| `aws.providers.cognito.version` | Version of the Cognito provider | `v0.41.0` |
| `aws.providers.bedrock.version` | Version of the Bedrock provider | `v0.41.0` |
| `aws.providers.cloudfront.version` | Version of the CloudFront provider | `v0.41.0` |
| `aws.providers.secretsmanager.version` | Version of the Secrets Manager provider | `v0.41.0` |

## Authentication

The chart supports three authentication methods:

1. **Secret**: Uses a Kubernetes secret containing AWS credentials
2. **IRSA**: Uses IAM Roles for Service Accounts
3. **EC2**: Uses the EC2 instance profile

### Using Secret Authentication

Create a Kubernetes secret with your AWS credentials:

```bash
kubectl create secret generic aws-credentials \
  --namespace crossplane-system \
  --from-literal=aws_access_key_id=YOUR_ACCESS_KEY \
  --from-literal=aws_secret_access_key=YOUR_SECRET_KEY
```

Then install the chart with:

```bash
helm install providers ./charts/providers \
  --set aws.authentication.method=secret \
  --set aws.authentication.secret.name=aws-credentials \
  --set aws.authentication.secret.namespace=crossplane-system
```

## License

This chart is licensed under the MIT License.
