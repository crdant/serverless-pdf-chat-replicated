# Serverless PDF Chat with Crossplane and Kubernetes

This project is a Kubernetes-native implementation of the [AWS Serverless PDF Chat](https://github.com/aws-samples/serverless-pdf-chat) application, using Crossplane to manage cloud resources and Helm charts for deployment. It enables natural language interactions with PDF documents by combining the power of LLMs for text generation with vector search for document context retrieval.

<p float="left">
  <img src="preview-1.png" width="49%" />
  <img src="preview-2.png" width="49%" />
</p>

## Why This Project Exists

This project demonstrates how software vendors with cloud-dependent applications can ship to customer environments today without waiting to refactor their applications to be cloud-agnostic:

- **Immediate Delivery**: Vendors can package applications with their cloud dependencies for customer-managed Kubernetes environments
- **Bridge to Multi-Cloud**: Start with the cloud you already use while preparing for a more portable future
- **Real-World Example**: Uses AWS's own showcase application to demonstrate how even heavily cloud-dependent workloads can be packaged
- **Complete Solution**: Combines containerized frontend components with Crossplane-managed cloud resources
- **Preferred Deployment**: Designed for deployment via the Replicated Embedded Cluster, providing a turnkey solution for customers

By using Crossplane to provision and manage AWS resources through Kubernetes, this approach allows vendors to ship software to customers on the same cloud platform immediately while maintaining a path toward future cloud portability through composite resources.

### The Replicated Advantage

This project showcases the end-to-end vendor-to-customer delivery process that Replicated enables for cloud-dependent applications:

- **Complete Distribution Pipeline**: Package, license, distribute, and update applications through a vendor portal
- **Software Licensing & Entitlements**: Manage customer access, feature entitlements, and subscription tiers
- **Customer-Specific Configuration**: Define configuration options customers can customize during installation
- **Secure Airgap Support**: Support customers with strict security requirements who operate in disconnected environments
- **Automated Updates**: Deliver application updates with versioning and release channels
- **Day-2 Operations**: Support troubleshooting with built-in support bundles and preflight checks
- **Installation Flexibility**: Support both connected and airgap installations with the same package

For customers, Replicated dramatically simplifies the installation and management experience:

- **Simplified Installation**: Install complex, cloud-dependent applications through a user-friendly installer
- **Reduced Prerequisites**: No existing Kubernetes cluster required
- **Consistent Updates**: Receive vendor updates through a controlled, tested process
- **Self-Hosted Control**: Maintain data sovereignty and security by running in your own environment

### Origin Story

This project was inspired by a conversation with a software vendor who identified a critical bootstrapping problem: they wanted to use Crossplane to create cloud resources including a Kubernetes cluster, but they needed a Kubernetes cluster to run Crossplane in the first place.

This circular dependency highlighted a perfect use case for the Replicated Embedded Cluster, which can serve as the bootstrap cluster for Crossplane. The Embedded Cluster provides the initial Kubernetes environment needed to run Crossplane, which can then provision additional cloud resources and even additional clusters if needed.

This approach solves the "chicken and egg" problem for vendors who want to use Crossplane's powerful resource provisioning capabilities but need a reliable, customer-friendly way to deploy that initial Kubernetes environment.

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

### Packaging with Replicated

This project is designed for distribution through Replicated, providing vendors with a complete software delivery platform and customers with a simple installation experience.

```bash
# Lint the release files
make lint

# Create a release in the Replicated vendor portal
make release
```

The Replicated CLI takes the packaged Helm charts and Docker images and creates a release that customers can install through the Embedded Cluster or into an existing Kubernetes cluster, with support for:

- Customer-specific configurations
- License management
- Airgap installations
- Automated updates
- Support bundle generation
- Admin console for application management

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