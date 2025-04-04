# Revised Plan for Serverless PDF Chat as Helm Charts with Crossplane

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

The goal is to maintain the serverless architecture while converting the infrastructure management into Helm charts using Crossplane:
- The React frontend will be containerized and run on Kubernetes
- The Lambda functions will remain as serverless AWS Lambda functions
- All AWS services (including Lambda) will be managed via Crossplane and Upbound providers
- All infrastructure configuration will be packaged as Helm charts

## Important Assumptions
1. A Kubernetes cluster with Crossplane already installed is available
2. Each provider from the AWS provider family will be defined in its own template

## High-Level Architecture

1. **Helm Chart Structure**:
   - `crossplane-providers` - Chart for Crossplane providers and configuration
   - `serverless-pdf-chat` - Chart for the frontend and AWS resources (including Lambda)

2. **Kubernetes Components**:
   - Frontend web application (deployment, service, ingress)

3. **Crossplane-Managed AWS Resources**:
   - Lambda functions
   - API Gateway
   - S3 buckets
   - DynamoDB tables
   - SQS queues
   - Cognito user pools
   - IAM roles and policies
   - Bedrock model access

4. **Application Container Images**:
   - Frontend container only

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

### Step 3: Lambda Functions as Crossplane Resources

1. Define Lambda functions using Crossplane
2. Configure function code and dependencies
3. Set up event sources and triggers
4. Configure IAM roles and permissions

### Step 4: API Gateway as Crossplane Resources

1. Define API Gateway using Crossplane
2. Configure routes and integrations with Lambda
3. Set up authentication and authorization

### Step 5: Containerize Frontend

1. Create Docker image for frontend
2. Configure Kubernetes deployment
3. Set up service and ingress

### Step 6: Application Helm Chart

1. Define application configuration
2. Create templates for all resources
3. Define dependencies between resources
4. Create deployment values file

### Step 7: Testing and Deployment

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

### Phase 4: Serverless Lambda Functions

1. Create Lambda function resources with Crossplane
2. Configure function code and dependencies
3. Set up event triggers
4. Test Lambda function deployment

### Phase 5: API Gateway Configuration

1. Create API Gateway resources with Crossplane
2. Configure routes and integrations
3. Set up authentication
4. Test API endpoints

### Phase 6: Containerize Frontend

1. Create Docker image for React frontend
2. Create Kubernetes deployment for frontend
3. Configure service and ingress
4. Test frontend deployment

### Phase 7: Integration and Testing

1. Connect frontend to API Gateway
2. Test end-to-end functionality
3. Optimize configuration

### Phase 8: Helm Chart Packaging and Documentation

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
   - Create separate template for each AWS provider (S3, DynamoDB, SQS, Lambda, API Gateway, etc.)
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
    - Create templates for Lambda execution roles
    - Define IAM policies for service access
    - Configure trust relationships
    - Add configuration values for IAM

11. **Test authentication flow**
    - Deploy authentication resources
    - Create test user in Cognito
    - Validate authentication process

### Phase 4: Lambda Function Resources

12. **Create Lambda function templates**
    - Create templates for each Lambda function
    - Configure function runtime and handler
    - Define memory and timeout settings
    - Add configuration values for Lambda functions

13. **Configure Lambda code and dependencies**
    - Create templates for function code source
    - Define packaging specifications
    - Configure environment variables
    - Add configuration values for function code

14. **Configure Lambda event sources**
    - Create templates for event sources (API Gateway, S3, etc.)
    - Define event mappings
    - Add configuration values for event sources

15. **Test Lambda function deployment**
    - Deploy Lambda resources
    - Verify function creation in AWS
    - Test function invocation

### Phase 5: API Gateway Resources

16. **Create API Gateway template**
    - Create template for REST API
    - Define API properties
    - Add configuration values for API Gateway

17. **Configure API routes and methods**
    - Create templates for API resources and methods
    - Define integrations with Lambda functions
    - Configure request/response mappings
    - Add configuration values for routes

18. **Set up API authentication**
    - Configure Cognito authorizer
    - Define authorization scopes
    - Add configuration values for authentication

19. **Test API Gateway deployment**
    - Deploy API Gateway resources
    - Verify API creation in AWS
    - Test API endpoints

### Phase 6: Application Chart Structure

20. **Create application chart structure**
    - Create `serverless-pdf-chat` chart with proper structure
    - Define Chart.yaml and values.yaml
    - Define dependencies on provider chart

21. **Create templates for AWS resources**
    - Create composite templates referencing infrastructure
    - Define resource compositions
    - Add configuration values for AWS resources

22. **Create Kubernetes resource templates**
    - Define namespace and service account templates
    - Create ConfigMap and Secret templates
    - Define common labels and annotations

### Phase 7: Frontend Containerization

23. **Create frontend Dockerfile**
    - Create Dockerfile for React application
    - Configure build process
    - Optimize for production

24. **Create frontend deployment template**
    - Define Deployment resource for frontend
    - Configure container settings
    - Define resource requirements
    - Add health checks

25. **Create frontend service and ingress**
    - Define Service resource for frontend
    - Create Ingress resource
    - Configure TLS (if needed)
    - Add configuration values

26. **Configure frontend environment**
    - Create ConfigMap for frontend configuration
    - Define environment variables for API access
    - Configure authentication settings

27. **Test frontend deployment**
    - Build and push frontend image
    - Deploy frontend resources
    - Validate frontend accessibility

### Phase 8: Integration and Testing

28. **Configure frontend-to-API integration**
    - Update frontend configuration to use API Gateway
    - Configure authentication flow
    - Test connectivity

29. **End-to-end testing**
    - Test document upload flow
    - Test chat conversation flow
    - Validate PDF processing and embedding

30. **Performance and scalability testing**
    - Test Lambda function performance
    - Validate auto-scaling
    - Optimize resource configuration

### Phase 9: Packaging and Documentation

31. **Package Helm charts**
    - Create chart archives
    - Configure chart repository
    - Manage chart versions

32. **Create documentation**
    - Document chart usage
    - Create installation guide
    - Document configuration options

33. **Create deployment pipeline**
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
      - provider-aws-lambda.yaml
      - provider-aws-apigateway.yaml
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
    - lambda:
      - version: "v0.41.0"
      - controllerConfig: {}
    - apigateway:
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
      - lambdaRole:
        - name: "lambda-execution-role"
        - assumeRolePolicyDocument: |
            {
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Effect": "Allow",
                  "Principal": {
                    "Service": "lambda.amazonaws.com"
                  },
                  "Action": "sts:AssumeRole"
                }
              ]
            }
        - policies:
          - name: "lambda-execution-policy"
            document: |
              {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Effect": "Allow",
                    "Action": [
                      "logs:CreateLogGroup",
                      "logs:CreateLogStream",
                      "logs:PutLogEvents"
                    ],
                    "Resource": "arn:aws:logs:*:*:*"
                  },
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
                  },
                  {
                    "Effect": "Allow",
                    "Action": [
                      "dynamodb:GetItem",
                      "dynamodb:PutItem",
                      "dynamodb:UpdateItem",
                      "dynamodb:DeleteItem",
                      "dynamodb:Query",
                      "dynamodb:Scan"
                    ],
                    "Resource": [
                      "${documentTableArn}",
                      "${memoryTableArn}"
                    ]
                  },
                  {
                    "Effect": "Allow",
                    "Action": [
                      "sqs:SendMessage",
                      "sqs:ReceiveMessage",
                      "sqs:DeleteMessage",
                      "sqs:GetQueueAttributes"
                    ],
                    "Resource": "${embeddingQueueArn}"
                  },
                  {
                    "Effect": "Allow",
                    "Action": [
                      "bedrock:InvokeModel"
                    ],
                    "Resource": "*"
                  }
                ]
              }

Create the following templates:
1. cognito.yaml - Define a Cognito User Pool using Crossplane's AWS provider, with appropriate configuration for email verification, user attributes, and password policy. Also include a User Pool Client.
2. iam.yaml - Define IAM roles and policies using Crossplane's AWS provider, including permissions for Lambda execution and access to S3, DynamoDB, SQS, and Bedrock.

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Make sure to include trust relationships in the IAM roles and reference other resources where necessary. Each resource should reference the appropriate provider configuration.

Include support for dynamic references to other AWS resources (like the S3 bucket ARN in the IAM policy) using Helm templating.
```

### Prompt 4: Lambda Function Resources

```
Now, let's create templates for the Lambda functions that will handle the serverless-pdf-chat application's business logic.

Add the following templates to the serverless-pdf-chat chart:
- templates/aws/lambda/
  - upload-trigger.yaml
  - generate-presigned-url.yaml
  - generate-embeddings.yaml
  - get-document.yaml
  - get-all-documents.yaml
  - delete-document.yaml
  - add-conversation.yaml
  - generate-response.yaml

Update the values.yaml file to include:
- aws:
  - lambda:
    - runtime: "python3.11"
    - handler: "lambda_function.lambda_handler"
    - timeout: 30
    - memorySize: 256
    - environment:
      - DOCUMENT_BUCKET: "{{ .Values.aws.s3.documentBucketName }}"
      - DOCUMENT_TABLE: "{{ .Values.aws.dynamodb.documentTable.name }}"
      - MEMORY_TABLE: "{{ .Values.aws.dynamodb.memoryTable.name }}"
      - EMBEDDING_QUEUE: "{{ .Values.aws.sqs.embeddingQueue.name }}"
      - EMBEDDING_MODEL_ID: "{{ .Values.application.config.embeddingModelId }}"
      - MODEL_ID: "{{ .Values.application.config.modelId }}"
      - REGION: "{{ .Values.application.config.region }}"
    - functions:
      - uploadTrigger:
          name: "upload-trigger"
          description: "Handles S3 uploads and triggers document processing"
          timeout: 30
          memorySize: 256
          codePath: "./lambda/upload_trigger"
          environment:
            - ADDITIONAL_ENV_VAR: "value"
      - generatePresignedUrl:
          name: "generate-presigned-url"
          description: "Generates presigned URLs for document uploads"
          timeout: 10
          memorySize: 128
          codePath: "./lambda/generate_presigned_url"
      - generateEmbeddings:
          name: "generate-embeddings"
          description: "Processes documents and generates embeddings"
          timeout: 180
          memorySize: 1024
          codePath: "./lambda/generate_embeddings"
      - getDocument:
          name: "get-document"
          description: "Retrieves document information"
          timeout: 10
          memorySize: 128
          codePath: "./lambda/get_document"
      - getAllDocuments:
          name: "get-all-documents"
          description: "Retrieves all user documents"
          timeout: 10
          memorySize: 128
          codePath: "./lambda/get_all_documents"
      - deleteDocument:
          name: "delete-document"
          description: "Deletes a document and its embeddings"
          timeout: 30
          memorySize: 256
          codePath: "./lambda/delete_document"
      - addConversation:
          name: "add-conversation"
          description: "Adds a new conversation to memory"
          timeout: 10
          memorySize: 128
          codePath: "./lambda/add_conversation"
      - generateResponse:
          name: "generate-response"
          description: "Generates a response using the LLM"
          timeout: 60
          memorySize: 512
          codePath: "./lambda/generate_response"

Create templates for each Lambda function, defining:
1. Function resource - Using Crossplane's AWS Lambda provider
2. Function code configuration - Either using S3 or ZIP file inline
3. Environment variables - Including references to other resources
4. IAM role configuration - Using the Lambda execution role
5. Timeout and memory settings - Based on function requirements

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Each resource should reference the appropriate provider configuration.

Include support for dynamic references to other AWS resources using Helm templating.

Note that the actual Lambda function code is not generated in this prompt - assume it's available in the paths specified in the values file.
```

### Prompt 5: API Gateway Resources

```
Now, let's create templates for the API Gateway that will serve as the frontend for our Lambda functions.

Add the following templates to the serverless-pdf-chat chart:
- templates/aws/
  - apigateway.yaml
  - apigateway-routes.yaml
  - apigateway-authorizer.yaml

Update the values.yaml file to include:
- aws:
  - apiGateway:
    - name: "pdf-chat-api"
    - description: "API for PDF Chat application"
    - endpointConfiguration: "REGIONAL"
    - corsEnabled: true
    - corsOrigins: ["*"]
    - stageName: "v1"
    - authorizer:
      - name: "cognito-authorizer"
      - type: "COGNITO_USER_POOLS"
      - identitySource: "method.request.header.Authorization"
      - providerARNs:
        - "{{ .Values.aws.cognito.userPool.arn }}"
    - routes:
      - generatePresignedUrl:
        - path: "/generate_presigned_url"
        - method: "GET"
        - function: "{{ .Values.aws.lambda.functions.generatePresignedUrl.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
      - getDocument:
        - path: "/doc/{documentid}/{conversationid}"
        - method: "GET"
        - function: "{{ .Values.aws.lambda.functions.getDocument.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
        - requestParameters:
          - "method.request.path.documentid": true
          - "method.request.path.conversationid": true
      - getAllDocuments:
        - path: "/doc"
        - method: "GET"
        - function: "{{ .Values.aws.lambda.functions.getAllDocuments.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
      - addConversation:
        - path: "/doc/{documentid}"
        - method: "POST"
        - function: "{{ .Values.aws.lambda.functions.addConversation.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
        - requestParameters:
          - "method.request.path.documentid": true
      - generateResponse:
        - path: "/{documentid}/{conversationid}"
        - method: "POST"
        - function: "{{ .Values.aws.lambda.functions.generateResponse.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
        - requestParameters:
          - "method.request.path.documentid": true
          - "method.request.path.conversationid": true
      - deleteDocument:
        - path: "/doc/{documentid}"
        - method: "DELETE"
        - function: "{{ .Values.aws.lambda.functions.deleteDocument.name }}"
        - authorizationType: "COGNITO_USER_POOLS"
        - requestParameters:
          - "method.request.path.documentid": true
    - domains:
      - name: "api.pdf-chat.example.com"
        - certificateArn: ""
        - basePath: ""

Create the following templates:
1. apigateway.yaml - Define the API Gateway REST API using Crossplane's AWS API Gateway provider, with proper CORS configuration.
2. apigateway-routes.yaml - Define the routes and method resources, with integrations to the Lambda functions.
3. apigateway-authorizer.yaml - Define the Cognito authorizer for authentication.

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Each resource should reference the appropriate provider configuration.

Include support for dynamic references to other AWS resources (like Lambda function ARNs) using Helm templating.

Configure proper response and request templates for the Lambda integrations.

Add support for custom domain mapping if specified.
```

### Prompt 6: Event Triggers and Lambda Permissions

```
Now, let's create templates for event triggers and permissions for our Lambda functions. This includes S3 event notifications and necessary permissions for API Gateway to invoke Lambda.

Add the following templates to the serverless-pdf-chat chart:
- templates/aws/
  - s3-notifications.yaml
  - lambda-permissions.yaml

Update the values.yaml file to include:
- aws:
  - s3Notifications:
    - uploadTrigger:
      - events: ["s3:ObjectCreated:*"]
      - filterPrefix: "uploads/"
      - filterSuffix: ".pdf"
      - function: "{{ .Values.aws.lambda.functions.uploadTrigger.name }}"
  - lambdaPermissions:
    - apiGateway:
      - sourceArn: "{{ .Values.aws.apiGateway.arn }}/*/GET/generate_presigned_url"
      - function: "{{ .Values.aws.lambda.functions.generatePresignedUrl.name }}"
    - s3:
      - sourceArn: "arn:aws:s3:::{{ .Values.aws.s3.documentBucketName }}"
      - function: "{{ .Values.aws.lambda.functions.uploadTrigger.name }}"

Create the following templates:
1. s3-notifications.yaml - Define S3 bucket notifications for triggering Lambda functions when objects are created, using Crossplane's AWS S3 provider.
2. lambda-permissions.yaml - Define permissions for services like API Gateway and S3 to invoke Lambda functions, using Crossplane's AWS Lambda provider.

Ensure all resources have proper naming based on the values file configuration and include appropriate metadata and labels. Each resource should reference the appropriate provider configuration.

Include support for dynamic references to other AWS resources (like S3 bucket ARNs and Lambda function ARNs) using Helm templating.

Configure proper source ARNs for the permissions to restrict who can invoke the Lambda functions.
```

### Prompt 7: Frontend Containerization

```
Now, let's create a Dockerfile and Kubernetes deployment resources for the frontend of our serverless-pdf-chat application.

First, create a Dockerfile for the React frontend:
- Use Node 18 as the base image for building
- Install dependencies
- Build the frontend with proper environment variable configuration
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
    - apiEndpoint: "https://{{ .Values.aws.apiGateway.domains.name }}/{{ .Values.aws.apiGateway.stageName }}"
    - region: "{{ .Values.application.config.region }}"
    - userPoolId: "{{ .Values.aws.cognito.userPool.id }}"
    - userPoolClientId: "{{ .Values.aws.cognito.userPoolClient.id }}"

Create the following templates:
1. deployment.yaml - Define a Deployment for the frontend, including resource limits, probes, security context, and environment variables.
2. service.yaml - Define a Service for the frontend, exposing the appropriate port.
3. ingress.yaml - Define an Ingress for the frontend, with TLS configuration if enabled.
4. configmap.yaml - Define a ConfigMap for frontend-specific configuration.

Ensure the frontend container has the necessary environment variables to connect to the AWS API Gateway and authenticate with Cognito. Use ConfigMap and Secret resources for configuration.

Include appropriate health checks (readiness and liveness probes) for the frontend container.

Add support for horizontal pod autoscaling based on the configuration.

Configure a proper init container if needed for any setup tasks.
```

### Prompt 8: Application Resources and References

```
Now, let's create templates for application resources and references to help manage the interconnected AWS resources.

Add the following templates to the serverless-pdf-chat chart:
- templates/
  - namespace.yaml
  - serviceaccount.yaml
  - aws-references.yaml
  - frontend-secrets.yaml

Update the values.yaml file to include:
- kubernetes:
  - namespace: "pdf-chat"
  - serviceAccount:
    - create: true
    - name: "pdf-chat"
    - annotations: {}
- application:
  - config:
    - region: "us-east-1"
    - embeddingModelId: "amazon.titan-embed-text-v2:0"
    - modelId: "anthropic.claude-3-sonnet-20240229
