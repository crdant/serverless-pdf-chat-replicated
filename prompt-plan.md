# Plan for Converting Serverless PDF Chat to Helm Charts with Crossplane

## Overview Analysis

The serverless-pdf-chat application is a PDF document chatbot application running on AWS using various serverless services:

1. **Frontend**: React application hosted on AWS Amplify
2. **Authentication**: Amazon Cognito
3. **API**: AWS API Gateway
4. **Business Logic**: Multiple AWS Lambda functions
5. **Storage**:
   - Amazon S3 for documents and embeddings
   - DynamoDB for document metadata and conversation memory
6. **Queue**: SQS for asynchronous embedding processing
7. **AI Services**: Amazon Bedrock for LLM and embedding models

The goal is to convert this architecture into Kubernetes using Helm charts, where:
- The application itself will run in containers on Kubernetes
- AWS services will be managed via Crossplane and Upbound providers
- All infrastructure configuration will be packaged as Helm charts

## Important Assumptions
1. A Kubernetes cluster with Crossplane already installed is available
2. Each provider from the AWS provider family will be defined in its own template

## High-Level Architecture for Kubernetes Migration

1. **Helm Chart Structure**:
   - `crossplane-providers` - Chart for Crossplane providers and configuration
   - `serverless-pdf-chat` - Chart for application and AWS resources

2. **Kubernetes Components**:
   - Frontend web application (deployment, service, ingress)
   - Backend services for each Lambda function (deployments, services)

3. **Crossplane-Managed AWS Resources**:
   - S3 buckets
   - DynamoDB tables
   - SQS queues
   - Cognito user pools
   - IAM roles and policies
   - Bedrock model access

4. **Application Container Images**:
   - Frontend container
   - Backend service containers for each Lambda function

## Detailed Implementation Plan

### Step 1: Crossplane Provider Installation

1. Create the Helm chart skeleton for AWS providers 
2. Configure AWS provider family with individual provider templates
3. Create provider configuration for AWS authentication

### Step 2: AWS Infrastructure as Crossplane Resources

1. Convert S3 resources to Crossplane XRs
2. Convert DynamoDB resources to Crossplane XRs
3. Convert SQS resources to Crossplane XRs
4. Convert Cognito resources to Crossplane XRs
5. Configure IAM roles and permissions

### Step 3: Containerize Application Components

1. Create Docker images for frontend
2. Create Docker images for Lambda functions
3. Configure Kubernetes deployments and services

### Step 4: Application Helm Chart

1. Define application configuration
2. Create templates for all Kubernetes resources
3. Define dependencies between resources
4. Create deployment values file

### Step 5: Testing and Deployment

1. Test charts with local Kubernetes
2. Deploy to a production Kubernetes environment
3. Validate functionality

## Iterative Implementation Plan

Breaking this down into smaller, iterative steps:

### Phase 1: Crossplane Provider Chart

1. Create basic Helm chart structure for AWS providers
2. Create individual templates for each AWS provider
3. Define provider configuration template with AWS authentication
4. Test provider installation

### Phase 2: Core Infrastructure Resources

1. Create S3 bucket resources with Crossplane
2. Create DynamoDB table resources
3. Create SQS queue resources
4. Test infrastructure provisioning

### Phase 3: Auth and Security Resources

1. Create Cognito user pool resources
2. Configure IAM roles and policies
3. Test authentication flow

### Phase 4: Containerize Frontend

1. Create Docker image for React frontend
2. Create Kubernetes deployment for frontend
3. Configure service and ingress
4. Test frontend deployment

### Phase 5: Containerize Backend Services

1. Create Docker images for each Lambda function
2. Create Kubernetes deployments for backend services
3. Configure service discovery
4. Test backend service deployments

### Phase 6: Integration and Configuration

1. Connect frontend to backend services
2. Configure environment variables
3. Test end-to-end functionality

### Phase 7: Helm Chart Packaging and Documentation

1. Package Helm charts
2. Document chart usage
3. Create CI/CD pipeline for chart deployment

## Refined, Smaller Steps for Implementation

Let's break these phases down into smaller, more manageable steps:

### Phase 1: Crossplane Provider Chart

1. **Create basic chart structure**
   - Create `crossplane-providers` chart with proper directory structure
   - Define basic Chart.yaml and values.yaml

2. **Create individual AWS provider templates**
   - Create separate template for each AWS provider (S3, DynamoDB, SQS, etc.)
   - Configure provider package sources
   - Define version and controller configuration for each

3. **Create AWS Provider configuration**
   - Define ProviderConfig template with AWS authentication
   - Configure region and other AWS settings
   - Add configuration values

4. **Test provider installation**
   - Deploy provider chart
   - Verify provider status
   - Validate provider connectivity to AWS

### Phase 2: Core Infrastructure Resources

5. **Create S3 bucket resources**
   - Create template for S3 bucket Crossplane resource
   - Define bucket properties and permissions
   - Add configuration values for S3

6. **Create DynamoDB table resources**
   - Create templates for document and memory tables
   - Define key schemas and capacity
   - Add configuration values for DynamoDB

7. **Create SQS queue resources**
   - Create template for embedding queue
   - Define queue properties
   - Add configuration values for SQS

8. **Test infrastructure provisioning**
   - Deploy infrastructure resources
   - Verify resource creation in AWS
   - Validate resource properties

### Phase 3: Auth and Security Resources

9. **Create Cognito resources**
   - Create template for user pool
   - Define user pool client
   - Configure user pool properties
   - Add configuration values for Cognito

10. **Configure IAM resources**
    - Create templates for IAM roles
    - Define IAM policies for service access
    - Configure trust relationships
    - Add configuration values for IAM

11. **Test authentication flow**
    - Deploy authentication resources
    - Create test user in Cognito
    - Validate authentication process

### Phase 4: Application Resources Chart

12. **Create application chart structure**
    - Create `serverless-pdf-chat` chart with proper structure
    - Define Chart.yaml and values.yaml
    - Define dependencies on provider chart

13. **Create templates for AWS resources**
    - Create composite templates referencing infrastructure
    - Define resource compositions
    - Add configuration values for AWS resources

14. **Create Kubernetes resource templates**
    - Define namespace and service account templates
    - Create ConfigMap and Secret templates
    - Define common labels and annotations

### Phase 5: Containerize Frontend

15. **Create frontend Dockerfile**
    - Create Dockerfile for React application
    - Configure build process
    - Optimize for production

16. **Create frontend deployment template**
    - Define Deployment resource for frontend
    - Configure container settings
    - Define resource requirements
    - Add health checks

17. **Create frontend service and ingress**
    - Define Service resource for frontend
    - Create Ingress resource
    - Configure TLS (if needed)
    - Add configuration values

18. **Test frontend deployment**
    - Build and push frontend image
    - Deploy frontend resources
    - Validate frontend accessibility

### Phase 6: Containerize Backend Services

19. **Create base backend Dockerfile**
    - Create common Dockerfile for Python services
    - Configure Python dependencies
    - Optimize for production

20. **Create document processing services**
    - Create Docker images for document upload and processing
    - Create deployment templates
    - Configure environment variables
    - Define resource requirements

21. **Create conversation services**
    - Create Docker images for conversation management
    - Create deployment templates
    - Configure environment variables
    - Define resource requirements

22. **Create response generation service**
    - Create Docker image for Bedrock integration
    - Create deployment template
    - Configure environment variables
    - Define resource requirements

23. **Test backend services**
    - Build and push backend images
    - Deploy backend resources
    - Validate service functionality

### Phase 7: API Gateway Replacement

24. **Create API service**
    - Create Docker image for API Gateway replacement
    - Configure routing rules
    - Create deployment template
    - Define service and ingress

25. **Configure authentication middleware**
    - Implement Cognito authentication
    - Configure JWT validation
    - Create deployment resources

26. **Test API functionality**
    - Deploy API resources
    - Validate routing and authentication
    - Test API endpoints

### Phase 8: Integration and Testing

27. **Configure environment connections**
    - Update frontend configuration to use Kubernetes services
    - Create service discovery mechanisms
    - Configure backend service communication

28. **End-to-end testing**
    - Test document upload flow
    - Test chat conversation flow
    - Validate PDF processing and embedding

29. **Performance and scalability testing**
    - Test under load
    - Configure horizontal scaling
    - Optimize resource usage

### Phase 9: Packaging and Documentation

30. **Package Helm charts**
    - Create chart archives
    - Configure chart repository
    - Manage chart versions

31. **Create documentation**
    - Document chart usage
    - Create installation guide
    - Document configuration options

32. **Create deployment pipeline**
    - Configure CI/CD for chart deployment
    - Create automated testing
    - Configure release process

## Final Implementation Prompts

Based on the refined steps above, here are the prompts that could be used for code generation:

### Prompt 1: Basic Chart Structure and Individual AWS Providers

```
I'm converting a serverless AWS application to run on Kubernetes using Crossplane to manage AWS resources. I already have a Kubernetes cluster with Crossplane installed, so I need to create a Helm chart for the AWS providers and configuration.

Let's start by creating a Helm chart called 'crossplane-providers' with the following structure:
- crossplane-providers/
  - Chart.yaml
  - values.yaml
  - templates/
    - _helpers.tpl
    - providerconfig.yaml
    - providers/
      - provider-aws-s3.yaml
      - provider-aws-dynamodb.yaml
      - provider-aws-sqs.yaml
      - provider-aws-cognito.yaml
      - provider-aws-iam.yaml
      - provider-aws-bedrock.yaml

For the Chart.yaml, include name, description, type, and version.

For values.yaml, define:
- aws:
  - region: us-east-1
  - providerConfigName: default
  - authentication:
    - type: Secret
    - secretName: aws-credentials
    - secretNamespace: crossplane-system
  - providers:
    - s3:
      - version: "v0.41.0"
      - controllerConfig: {}
    - dynamodb:
      - version: "v0.41.0"
      - controllerConfig: {}
    - sqs:
      - version: "v0.41.0"
      - controllerConfig: {}
    - cognito:
      - version: "v0.41.0"
      - controllerConfig: {}
    - iam:
      - version: "v0.41.0"
      - controllerConfig: {}
    - bedrock:
      - version: "v0.41.0"
      - controllerConfig: {}

Create individual provider templates for each AWS service (provider-aws-*.yaml), each defining a separate Provider resource from the Upbound AWS provider family.

Create a provider configuration template (providerconfig.yaml) that will use AWS credentials from a Kubernetes secret to authenticate with AWS.

Also, create a _helpers.tpl with common template functions like defining standard labels and metadata.

Assume that the AWS credentials secret already exists in the cluster, but provide instructions on how to create it if needed.
```

### Prompt 2: Core Infrastructure Resources Templates

```
Now, let's create templates for the core AWS infrastructure resources needed for our serverless-pdf-chat application. These should be added to a separate Helm chart called 'serverless-pdf-chat'.

Create the following chart structure:
- serverless-pdf-chat/
  - Chart.yaml
  - values.yaml
  - templates/
    - _helpers.tpl
    - aws/
      - s3.yaml
      - dynamodb.yaml
      - sqs.yaml

In Chart.yaml, include a dependency on the crossplane-providers chart.

In values.yaml, include configuration for:
- global:
  - namePrefix: "pdf-chat"
  - environment: "dev"
- aws:
  - providerConfigName: "default" # Reference to the ProviderConfig from crossplane-providers
  - s3:
    - documentBucketName: ""
    - corsEnabled: true
    - publicAccessBlockConfiguration:
      - blockPublicAcls: true
      - blockPublicPolicy: true
      - ignorePublicAcls: true
      - restrictPublicBuckets: true
  - dynamodb:
    - documentTable:
      - name: ""
      - keySchema:
        - attributeName: "userid"
          keyType: "HASH"
        - attributeName: "documentid"
          keyType: "RANGE"
      - attributeDefinitions:
        - attributeName: "userid"
          attributeType: "S"
        - attributeName: "documentid"
          attributeType: "S"
    - memoryTable:
      - name: ""
      - keySchema:
        - attributeName: "SessionId"
          keyType: "HASH"
      - attributeDefinitions:
        - attributeName: "SessionId"
          attributeType: "S"
    - billingMode: "PAY_PER_REQUEST"
  - sqs:
    - embeddingQueue:
      - name: ""
      - visibilityTimeout: 180
      - messageRetentionPeriod: 3600

Create the following templates:
1. s3.yaml - Define an S3 bucket using Crossplane's AWS provider, with proper configuration for CORS, public access blocking, and enforced HTTPS.
2. dynamodb.yaml - Define two DynamoDB tables using Crossplane's AWS provider, with key schemas matching the original application.
3. sqs.yaml - Define an SQS queue using Crossplane's AWS provider, with proper visibility timeout and retention period.

Create a _helpers.tpl with common template functions like defining standard labels and forming resource names.

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Each resource should reference the appropriate provider configuration.
```

### Prompt 3: Authentication and Security Resources

```
Let's continue building our serverless-pdf-chat Helm chart by adding templates for authentication and security resources.

Add the following templates to the serverless-pdf-chat chart:
- templates/aws/
  - cognito.yaml
  - iam.yaml

Update the values.yaml file to include:
- aws:
  - cognito:
    - userPool:
      - name: ""
      - autoVerifiedAttributes: ["email"]
      - usernameAttributes: ["email"]
      - adminCreateUserConfig:
        - allowAdminCreateUserOnly: true
      - passwordPolicy:
        - minimumLength: 8
        - requireLowercase: true
        - requireNumbers: true
        - requireSymbols: true
        - requireUppercase: true
    - userPoolClient:
      - name: ""
      - generateSecret: false
  - iam:
    - roles:
      - s3Role:
        - name: "s3-access-role"
        - assumeRolePolicyDocument: |
            {
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Effect": "Allow",
                  "Principal": {
                    "Service": "ec2.amazonaws.com"
                  },
                  "Action": "sts:AssumeRole"
                }
              ]
            }
        - policies:
          - name: "s3-access-policy"
            document: |
              {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Effect": "Allow",
                    "Action": [
                      "s3:GetObject",
                      "s3:PutObject",
                      "s3:ListBucket"
                    ],
                    "Resource": [
                      "arn:aws:s3:::${documentBucketName}",
                      "arn:aws:s3:::${documentBucketName}/*"
                    ]
                  }
                ]
              }
      - dynamoDBRole:
        - name: "dynamodb-access-role"
        - assumeRolePolicyDocument: |
            # Trust policy JSON
        - policies:
          - name: "dynamodb-access-policy"
            document: |
              # Policy JSON
      - bedrockRole:
        - name: "bedrock-access-role"
        - assumeRolePolicyDocument: |
            # Trust policy JSON
        - policies:
          - name: "bedrock-access-policy"
            document: |
              # Policy JSON
      - sqsRole:
        - name: "sqs-access-role"
        - assumeRolePolicyDocument: |
            # Trust policy JSON
        - policies:
          - name: "sqs-access-policy"
            document: |
              # Policy JSON

Create the following templates:
1. cognito.yaml - Define a Cognito User Pool using Crossplane's AWS provider, with appropriate configuration for email verification, user attributes, and password policy. Also include a User Pool Client.
2. iam.yaml - Define IAM roles and policies using Crossplane's AWS provider, including permissions for accessing S3, DynamoDB, SQS, and Bedrock.

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Make sure to include trust relationships in the IAM roles and reference other resources where necessary. Each resource should reference the appropriate provider configuration.

Include support for dynamic references to other AWS resources (like the S3 bucket ARN in the IAM policy) using Helm templating.
```

### Prompt 4: Application Kubernetes Resources

```
Now, let's set up the Kubernetes resources for our serverless-pdf-chat application.

Add the following templates to the serverless-pdf-chat chart:
- templates/
  - namespace.yaml
  - serviceaccount.yaml
  - configmap.yaml
  - secret.yaml

Update the values.yaml file to include:
- kubernetes:
  - namespace: "pdf-chat"
  - serviceAccount:
    - create: true
    - name: "pdf-chat"
    - annotations: {}
  - podSecurityContext:
    - fsGroup: 1000
  - securityContext:
    - capabilities:
      - drop: ["ALL"]
    - readOnlyRootFilesystem: true
    - runAsNonRoot: true
    - runAsUser: 1000
- application:
  - config:
    - region: "us-east-1"
    - embeddingModelId: "amazon.titan-embed-text-v2:0"
    - modelId: "anthropic.claude-3-sonnet-20240229-v1:0"
  - secrets:
    - createAWSSecrets: true  # Whether to create secrets for AWS resource names

Create the following templates:
1. namespace.yaml - Define a Kubernetes namespace for the application.
2. serviceaccount.yaml - Define a Kubernetes service account for the application.
3. configmap.yaml - Define a ConfigMap containing application configuration, including AWS region, API endpoint, and other non-sensitive settings.
4. secret.yaml - Define a Secret containing sensitive configuration, such as references to AWS resources.

Update the _helpers.tpl to include functions for:
- Generating common labels across all resources
- Forming full resource names with prefixes
- Creating standard metadata blocks
- Adding standard selectors

Ensure all resources have proper naming and include appropriate metadata and labels. Make sure to use the values from the values.yaml file for configuration.

Add conditional logic to create different resources based on configuration options (like whether to create a service account or not).

Include support for annotations on resources, especially for integration with other Kubernetes components or service meshes.
```

### Prompt 5: Frontend Containerization and Deployment

```
Let's create a Dockerfile and Kubernetes deployment resources for the frontend of our serverless-pdf-chat application.

First, create a Dockerfile for the React frontend:
- Use Node 18 as the base image for building
- Install dependencies
- Build the frontend
- Use a multi-stage build approach
- In the final stage, use Nginx as the base image to serve static files
- Configure Nginx properly for a single-page application

Then, add the following templates to the serverless-pdf-chat chart:
- templates/frontend/
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - configmap.yaml

Update the values.yaml file to include:
- frontend:
  - enabled: true
  - image:
    - repository: "your-registry/pdf-chat-frontend"
    - tag: "latest"
    - pullPolicy: "IfNotPresent"
  - replicaCount: 1
  - resources:
    - limits:
      - cpu: "200m"
      - memory: "256Mi"
    - requests:
      - cpu: "100m"
      - memory: "128Mi"
  - autoscaling:
    - enabled: false
    - minReplicas: 1
    - maxReplicas: 5
    - targetCPUUtilizationPercentage: 80
  - podSecurityContext: {}
  - securityContext: {}
  - nodeSelector: {}
  - tolerations: []
  - affinity: {}
  - podAnnotations: {}
  - service:
    - type: "ClusterIP"
    - port: 80
    - annotations: {}
  - ingress:
    - enabled: true
    - className: "nginx"
    - annotations: {}
    - hosts:
      - host: "pdf-chat.example.com"
        paths:
          - path: "/"
            pathType: "Prefix"
    - tls:
      - secretName: "pdf-chat-tls"
        hosts:
          - "pdf-chat.example.com"
  - config:
    - apiEndpoint: "https://api.pdf-chat.example.com"
    - region: "{{ .Values.application.config.region }}"

Create the following templates:
1. deployment.yaml - Define a Deployment for the frontend, including resource limits, probes, security context, and environment variables. Include autoscaling configuration.
2. service.yaml - Define a Service for the frontend, exposing the appropriate port.
3. ingress.yaml - Define an Ingress for the frontend, with TLS configuration if enabled.
4. configmap.yaml - Define a ConfigMap for frontend-specific configuration.

Ensure the frontend container has the necessary environment variables to connect to the AWS resources and API Gateway. Use ConfigMap and Secret resources for configuration.

Include appropriate health checks (readiness and liveness probes) for the frontend container.

Add support for horizontal pod autoscaling based on the configuration.

Configure a proper init container if needed for any setup tasks.
```

### Prompt 6: Backend Services Containerization

```
Now, let's create Dockerfiles and Kubernetes deployment resources for the backend services that will replace the Lambda functions in our serverless-pdf-chat application.

First, create a base Dockerfile for Python services:
- Use Python 3.11 as the base image
- Install common dependencies from requirements.txt
- Configure environment
- Follow best practices for container security and optimization

Then, create specific Dockerfiles for each service:
1. Document Upload Service (replaces upload_trigger, generate_presigned_url)
2. Document Processing Service (replaces generate_embeddings)
3. Document Management Service (replaces get_document, get_all_documents, delete_document)
4. Conversation Service (replaces add_conversation)
5. Response Generation Service (replaces generate_response)

Add the following templates to the serverless-pdf-chat chart:
- templates/backend/
  - document-upload/
    - deployment.yaml
    - service.yaml
    - configmap.yaml
  - document-processing/
    - deployment.yaml
    - service.yaml
    - configmap.yaml
  - document-management/
    - deployment.yaml
    - service.yaml
    - configmap.yaml
  - conversation/
    - deployment.yaml
    - service.yaml
    - configmap.yaml
  - response-generation/
    - deployment.yaml
    - service.yaml
    - configmap.yaml

Update the values.yaml file to include configuration for each backend service:
- backend:
  - common:
    - image:
      - pullPolicy: "IfNotPresent"
    - resources:
      - limits:
        - cpu: "500m"
        - memory: "512Mi"
      - requests:
        - cpu: "100m"
        - memory: "256Mi"
    - podSecurityContext: {}
    - securityContext: {}
    - nodeSelector: {}
    - tolerations: []
    - affinity: {}
  - documentUpload:
    - enabled: true
    - image:
      - repository: "your-registry/pdf-chat-document-upload"
      - tag: "latest"
    - replicaCount: 2
    - autoscaling:
      - enabled: true
      - minReplicas: 2
      - maxReplicas: 5
      - targetCPUUtilizationPercentage: 70
    - config:
      - port: 8080
      - timeoutSeconds: 30
  - documentProcessing:
    - enabled: true
    - image:
      - repository: "your-registry/pdf-chat-document-processing"
      - tag: "latest"
    - replicaCount: 2
    - autoscaling:
      - enabled: true
      - minReplicas: 2
      - maxReplicas: 5
      - targetCPUUtilizationPercentage: 70
    - config:
      - port: 8080
      - timeoutSeconds: 180
      - memoryLimit: "1Gi"
  # ... similar configuration for other services

Create deployment templates for each service, including:
- Resource limits and requests
- Health checks (readiness and liveness probes)
- Security context settings
- Environment variables
- Volume mounts (if needed)
- Autoscaling configuration

Create service templates for each service, defining appropriate ports and selectors.

Create configmap templates for service-specific configuration.

Ensure each service has the necessary environment variables to connect to the AWS resources managed by Crossplane. Use references to the outputs of the AWS resources.

Include proper error handling and graceful shutdown in the container configurations.

Support horizontal pod autoscaling for each service based on the configuration.
```

### Prompt 7: API Gateway Service

```
Let's create a Kubernetes-native API Gateway service to replace the AWS API Gateway used in the original serverless-pdf-chat application.

First, create a Dockerfile for an API Gateway service:
- Use a lightweight base image like Node.js
- Install Express or another API framework
- Configure routing and middleware
- Set up authentication integration with Cognito
- Optimize for performance and security

Add the following templates to the serverless-pdf-chat chart:
- templates/api/
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - configmap.yaml
  - hpa.yaml

Update the values.yaml file to include:
- api:
  - enabled: true
  - image:
    - repository: "your-registry/pdf-chat-api"
    - tag: "latest"
    - pullPolicy: "IfNotPresent"
  - replicaCount: 2
  - resources:
    - limits:
      - cpu: "300m"
      - memory: "384Mi"
    - requests:
      - cpu: "100m"
      - memory: "128Mi"
  - autoscaling:
    - enabled: true
    - minReplicas: 2
    - maxReplicas: 10
    - targetCPUUtilizationPercentage: 70
  - podSecurityContext: {}
  - securityContext: {}
  - nodeSelector: {}
  - tolerations: []
  - affinity: {}
  - podAnnotations: {}
  - service:
    - type: "ClusterIP"
    - port: 80
    - annotations: {}
  - ingress:
    - enabled: true
    - className: "nginx"
    - annotations:
      - "nginx.ingress.kubernetes.io/rewrite-target": "/$2"
    - hosts:
      - host: "api.pdf-chat.example.com"
        paths:
          - path: "/api(/|$)(.*)"
            pathType: "Prefix"
    - tls:
      - secretName: "pdf-chat-api-tls"
        hosts:
          - "api.pdf-chat.example.com"
  - config:
    - port: 8080
    - logLevel: "info"
    - timeout: 30000
    - corsEnabled: true
    - corsOrigins:
      - "*"
  - routes:
    - path: "/generate_presigned_url"
      service: "document-upload"
      port: 8080
      method: "GET"
    - path: "/doc/:documentid/:conversationid"
      service: "document-management"
      port: 8080
      method: "GET"
    - path: "/doc"
      service: "document-management"
      port: 8080
      method: "GET"
    - path: "/doc/:documentid"
      service: "conversation"
      port: 8080
      method: "POST"
    - path: "/:documentid/:conversationid"
      service: "response-generation"
      port: 8080
      method: "POST"
    - path: "/doc/:documentid"
      service: "document-management"
      port: 8080
      method: "DELETE"
  - auth:
    - enabled: true
    - cognito:
      - userPoolId: "{{ .Values.aws.cognito.userPool.id }}"
      - userPoolClientId: "{{ .Values.aws.cognito.userPoolClient.id }}"
      - region: "{{ .Values.application.config.region }}"
    - excludedPaths: []

Create the following templates:
1. deployment.yaml - Define a Deployment for the API Gateway, including resource limits, probes, security context, and environment variables.
2. service.yaml - Define a Service for the API Gateway, exposing the appropriate port.
3. ingress.yaml - Define an Ingress for the API Gateway, with TLS configuration if enabled.
4. configmap.yaml - Define a ConfigMap containing API Gateway configuration, including routes and authentication settings.
5. hpa.yaml - Define a HorizontalPodAutoscaler for the API Gateway.

Ensure the API Gateway service has the necessary environment variables to connect to backend services and authenticate requests. Use ConfigMap and Secret resources for configuration.

Include support for proper CORS configuration.

Configure the API Gateway to validate JWT tokens from Cognito for authentication.

Set up proper health checks and monitoring endpoints.

Include rate limiting capabilities to protect backend services.
```

### Prompt 8: Integration and Configuration

```
Now, let's integrate all the components of our serverless-pdf-chat application and ensure they can communicate with each other properly.

Update the frontend configuration to point to the new API Gateway service. Add the following environment variables to the frontend deployment:
- REACT_APP_API_ENDPOINT: "{{ .Values.frontend.config.apiEndpoint }}"
- REACT_APP_REGION: "{{ .Values.application.config.region }}"
- REACT_APP_USER_POOL_ID: "{{ .Values.aws.cognito.userPool.id }}"
- REACT_APP_USER_POOL_CLIENT_ID: "{{ .Values.aws.cognito.userPoolClient.id }}"

Create a new ConfigMap template specifically for environment variables and service connections:
- templates/connections-configmap.yaml

Update the values.yaml file to include connection information for all services:
- connections:
  - frontend:
    - apiEndpoint: "https://api.pdf-chat.example.com"
  - documentUpload:
    - s3BucketRef: 
      name: "{{ .Release.Name }}-document-bucket"
      namespace: "{{ .Release.Namespace }}"
    - documentTableRef:
      name: "{{ .Release.Name }}-document-table"
      namespace: "{{ .Release.Namespace }}"
    - memoryTableRef:
      name: "{{ .Release.Name }}-memory-table"
      namespace: "{{ .Release.Namespace }}"
    - embeddingQueueRef:
      name: "{{ .Release.Name }}-embedding-queue"
      namespace: "{{ .Release.Namespace }}"
  - documentProcessing:
    - s3BucketRef: 
      name: "{{ .Release.Name }}-document-bucket"
      namespace: "{{ .Release.Namespace }}"
    - documentTableRef:
      name: "{{ .Release.Name }}-document-table"
      namespace: "{{ .Release.Namespace }}"
    - embeddingModelId: "{{ .Values.application.config.embeddingModelId }}"
  - documentManagement:
    - s3BucketRef: 
      name: "{{ .Release.Name }}-document-bucket"
      namespace: "{{ .Release.Namespace }}"
    - documentTableRef:
      name: "{{ .Release.Name }}-document-table"
      namespace: "{{ .Release.Namespace }}"
    - memoryTableRef:
      name: "{{ .Release.Name }}-memory-table"
      namespace: "{{ .Release.Namespace }}"
  - conversation
