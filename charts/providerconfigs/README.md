# Crossplane Provider Configurations Helm Chart

This Helm chart configures AWS and Kubernetes provider configurations for Crossplane. It sets up the necessary credentials and configurations to allow Crossplane providers to interact with AWS services and the Kubernetes cluster.

## Overview

The chart creates the following resources:

- AWS ProviderConfig - Configures authentication and region for AWS Crossplane providers
- Kubernetes ProviderConfig - Configures authentication for the Kubernetes Crossplane provider
- AWS Credentials Secret - Creates a secret containing AWS credentials for the secret authentication method

## Prerequisites

- Kubernetes cluster with Crossplane installed
- Crossplane AWS and Kubernetes providers installed (you can use the `providers` chart for this)
- Helm 3.0+

## Installation

```bash
helm install providerconfigs ./charts/providerconfigs \
  --set aws.region=us-west-2
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override the name of the chart | `""` |
| `fullnameOverride` | Override the full name of the chart | `""` |
| `commonLabels` | Common labels to add to all resources | `{}` |
| `commonAnnotations` | Common annotations to add to all resources | `{}` |
| `aws.region` | AWS region where resources will be provisioned | `us-west-2` |
| `aws.providerConfigName` | Name of the AWS provider configuration | `default` |
| `aws.authentication.method` | Method to authenticate with AWS (currently only secret is supported) | `secret` |
| `aws.authentication.secret.name` | Name of the secret containing AWS credentials | `aws-credentials` |
| `aws.authentication.secret.namespace` | Namespace where the secret is located | `crossplane-system` |
| `aws.authentication.secret.keys.accessKeyId` | Key for AWS access key ID | `aws_access_key_id` |
| `aws.authentication.secret.keys.secretAccessKey` | Key for AWS secret access key | `aws_secret_access_key` |
| `kubernetes.providerConfigName` | Name of the Kubernetes provider configuration | `default` |
| `kubernetes.authentication.source` | Source of credentials for Kubernetes | `InjectedIdentity` |

## Authentication Method

Currently, this chart only supports the `secret` authentication method for AWS. The secret method uses a Kubernetes secret containing AWS credentials:

```yaml
aws:
  authentication:
    method: secret
    secret:
      name: aws-credentials
      namespace: crossplane-system
      keys:
        accessKeyId: "AKIAIOSFODNN7EXAMPLE"
        secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

Support for other authentication methods (IRSA, EC2) may be added in future versions.

## Usage with Compositions

Once this chart is installed, you can reference the provider configurations in your Crossplane compositions:

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: example
spec:
  resources:
    - name: s3bucket
      base:
        apiVersion: s3.aws.upbound.io/v1beta1
        kind: Bucket
        spec:
          forProvider:
            region: us-west-2
          providerConfigRef:
            name: default  # This should match aws.providerConfigName
```

## License

This chart is licensed under the MIT License.
