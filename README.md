# Serverless PDF Chat with Crossplane and Replicated

This project demonstrates how software vendors can deliver cloud-dependent applications to customer environments using the [Replicated Platform](https://www.replicated.com/) and [Crossplane](https://crossplane.io/). It reimagines the [AWS Serverless PDF Chat](https://github.com/aws-samples/serverless-pdf-chat) application as a distributable product that customers can easily install and operate in their own environments.

The application enables natural language interactions with PDF documents by combining LLMs for text generation with vector search for document context retrieval - all while showcasing how Replicated solves the end-to-end delivery challenges for complex, cloud-dependent applications.

<p float="left">
  <img src="preview-1.png" width="49%" />
  <img src="preview-2.png" width="49%" />
</p>

## Why This Project Exists

Many software vendors who could benefit from shipping their products to customer environments are constrained by cloud dependencies. The Replicated Platform solves this challenge by enabling vendors to:

- **Ship Today, Not Tomorrow**: Deliver cloud-dependent applications to customers immediately without refactoring
- **Bridge to Multi-Cloud**: Start with the cloud you already use while preparing for a more portable future
- **Simplify Customer Operations**: Provide a turnkey experience that dramatically reduces installation and management complexity
- **Support Any Environment**: Deploy to customer infrastructure whether connected, air-gapped, or highly regulated
- **Maintain Cloud Capabilities**: Preserve the power of cloud services while running in customer environments

This project uses an AWS showcase application to demonstrate how even heavily cloud-dependent workloads with numerous serverless components can be packaged and delivered as a complete product using the Replicated Platform.

### How the Replicated Platform Makes This Possible

The Replicated Platform provides a complete solution for delivering this application to customers. Vendor teams can focus on delivering value while Replicated handles the software distribution process with: release management, customer licensing, license management, release channels for controlling update availability, and detailed customer analytics and installation metrics.

The Replicated Embedded Cluster solves a very specific problem in this use case. It solves the "chicken and egg" problem by providing a lightweight, customer-managed Kubernetes environment that runs directly on VMs or bare metal. This cluster provides the bootstrap environment needed to run Crossplane without requiring a pre-existing Kubernetes cluster. It's also a consistent, vendor-controlled foundation for deploying cloud-dependent applications.

### Origin Story

This project was inspired by a conversation with a software vendor who identified a critical bootstrapping problem: they wanted to use Crossplane to create cloud resources including a Kubernetes cluster, but they needed a Kubernetes cluster to run Crossplane in the first place.

This circular dependency highlighted why a complete platform approach is necessary. The Replicated Platform solves this challenge through:

1. The **Embedded Cluster** provides the initial Kubernetes environment to run Crossplane
2. **Crossplane** then provisions and manages the needed cloud resources
3. The **KOTS Admin Console** gives customers visibility and control

Together, these components create a seamless experience that resolves the "chicken and egg" problem while providing the governance, security, and usability features that both vendors and enterprise customers require.

## Architecture Overview

![Serverless PDF Chat architecture](architecture.png "Serverless PDF Chat architecture")

This application maintains the serverless architecture of the original project, but uses Crossplane to provision and manage AWS resources through Kubernetes:

1. Users upload PDF documents to an Amazon S3 bucket through the React frontend
2. Document processing triggers a metadata extraction and embedding process using Amazon Bedrock
3. When users ask questions, a Lambda function retrieves relevant document vectors and contexts
4. An LLM (Amazon Bedrock) uses the retrieved context, conversation history, and its capabilities to generate responses

## Key Components

- **Frontend**: React application containerized with Nginx
- **Cloud Resources** (managed by Crossplane):
  - **Amazon Bedrock**: For serverless embedding and LLM inference
  - **AWS Lambda**: For serverless compute functions
  - **Amazon DynamoDB**: For document metadata and conversation storage
  - **Amazon S3**: For document storage and vector database
  - **Amazon SQS**: For processing queues
  - **Amazon Cognito**: For user authentication
  - **Amazon API Gateway**: For REST API endpoints

## Helm Chart Structure

The application is deployed using a set of Helm charts:

- **providers**: Installs Crossplane providers for AWS services
- **providerconfigs**: Configures AWS authentication and regions
- **compositions**: Defines high-level composite resources
- **serverless-pdf-chat**: The main application chart that provisions all components

## Prerequisites

### Preferred Deployment Method

- [Replicated Embedded Cluster](https://docs.replicated.com/vendor/embedded-cluster-overview) for turnkey customer deployment
- [Replicated CLI](https://github.com/replicatedhq/replicated) (for packaging releases)
- AWS account with [Amazon Bedrock model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)

### Alternative Deployment

- Kubernetes cluster (1.22+)
- [Crossplane](https://crossplane.io/) installed on your cluster
- [Helm](https://helm.sh/) (v3+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- AWS account with [Amazon Bedrock model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)
- Docker (for building images)
- AWS CLI (configured with appropriate credentials)

## Installation

### 1. Configure AWS Credentials

Ensure your AWS credentials are properly configured. Crossplane will use these to provision AWS resources.

```bash
aws configure
```

### 2. Install Crossplane Providers

```bash
helm install providers ./charts/providers
```

### 3. Configure Providers

```bash
# Create a secret with AWS credentials if not using instance roles
kubectl create secret generic aws-creds \
  --from-literal=aws_access_key_id=<YOUR_ACCESS_KEY> \
  --from-literal=aws_secret_access_key=<YOUR_SECRET_KEY>

# Install provider configurations
helm install providerconfigs ./charts/providerconfigs \
  --set aws.region=us-east-1 \
  --set aws.credentialsSecretName=aws-creds
```

### 4. Install Compositions

```bash
helm install compositions ./charts/compositions
```

### 5. Build and Push Docker Images

```bash
# Set environment variables
export AWS_REGION=us-east-1
export DOCKER_REGISTRY=<your-account-id>.dkr.ecr.us-east-1.amazonaws.com
export DOCKER_REPO=serverless-pdf-chat

# Login to ECR
make ecr-login

# Build and push all images
make images
```

### 6. Deploy the Application

```bash
helm install serverless-pdf-chat ./charts/serverless-pdf-chat \
  --set aws.region=us-east-1 \
  --set modelId=anthropic.claude-3-sonnet-20240229-v1:0 \
  --set image.repository=${DOCKER_REGISTRY}/${DOCKER_REPO}
```

### 7. Create a Cognito User

After deployment, create a user in the Cognito user pool:

1. Navigate to the AWS Cognito console
2. Find the user pool created by Crossplane
3. Add a new user with email and password
4. Use these credentials to log into the application

## Development

### Building Docker Images

```bash
# Build a specific image
make image-build-frontend

# Push a specific image
make image-push-frontend

# Build and push all images
make images
```

### Working with Helm Charts

```bash
# Lint charts
helm lint charts/serverless-pdf-chat

# Render templates
helm template charts/serverless-pdf-chat

# Package charts
make charts
```

### Creating Releases with the Replicated Platform

The Replicated Platform streamlines the entire release process from development to customer deployment:

```bash
# Lint the release files
make lint

# Create a release in the Replicated vendor portal
make release
```

When you create a release:

1. The Replicated CLI packages your Helm charts and references to Docker images
2. The release is published to your Replicated vendor portal
3. Customers can install through various methods including:
   - The Embedded Cluster installer for simple VM deployment
   - Existing Kubernetes clusters with the KOTS plugin
   - Air-gapped environments with offline packages

Each release automatically includes Replicated Platform features:
- Installation preflight checks
- Custom branding
- Role-based access control
- Application status monitoring
- Built-in troubleshooting tools
- Update notifications and controls

## Customization

### Model Selection

By default, this application uses:
- **Titan Embeddings G1 - Text** for vector embeddings
- **Anthropic Claude v3 Sonnet** for responses

To use different models, update the `modelId` value in your Helm chart:

```bash
helm install serverless-pdf-chat ./charts/serverless-pdf-chat \
  --set modelId=ai21.j2-ultra-v1
```

### Configuration Options

See the `values.yaml` files in each chart for detailed configuration options:

- `providers/values.yaml`: Crossplane provider versions and settings
- `providerconfigs/values.yaml`: AWS region and authentication
- `compositions/values.yaml`: Composition settings and references
- `serverless-pdf-chat/values.yaml`: Application-specific settings

## Security Notes

This application is designed for demonstration purposes and includes several security considerations for production use:

- Use AWS KMS with DynamoDB, SQS, and S3 for controlled encryption keys
- Configure API Gateway access logging and usage plans
- Enable S3 access logging
- Scope down IAM policies to more restrictive permissions
- Consider attaching Lambda functions to a VPC for network traffic inspection

## License

This project is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file for details.
