# Serverless PDF Chat - Helm/Crossplane Migration Todo List

## Project Overview

This is a detailed task list for migrating the PDF Chat application to Kubernetes using Helm and Crossplane, while preserving the original serverless Lambda architecture. 

Instead of containerizing the Lambda functions, we'll use Crossplane to manage the AWS Lambda resources directly, and only containerize the frontend for deployment to Kubernetes.

## Phase 1: Crossplane Provider Chart Setup

- [ ] **Create Crossplane providers chart structure**
  - [ ] Create `crossplane-providers/` directory
  - [ ] Create basic `Chart.yaml` with name, description, and version
  - [ ] Create initial `values.yaml` file with AWS region and authentication settings
  - [ ] Create `templates/` directory

- [ ] **Set up common chart functions**
  - [ ] Create `_helpers.tpl`
  - [ ] Add functions for common labels
  - [ ] Add functions for metadata generation
  - [ ] Add functions for name formatting

- [ ] **Create AWS provider templates**
  - [ ] Create template for S3 provider (`provider-aws-s3.yaml`)
  - [ ] Create template for DynamoDB provider (`provider-aws-dynamodb.yaml`)
  - [ ] Create template for SQS provider (`provider-aws-sqs.yaml`)
  - [ ] Create template for Lambda provider (`provider-aws-lambda.yaml`)
  - [ ] Create template for API Gateway provider (`provider-aws-apigateway.yaml`)
  - [ ] Create template for Cognito provider (`provider-aws-cognito.yaml`)
  - [ ] Create template for IAM provider (`provider-aws-iam.yaml`)
  - [ ] Create template for Bedrock provider (`provider-aws-bedrock.yaml`)
  
- [ ] **Configure AWS provider authentication**
  - [ ] Create provider configuration template (`providerconfig.yaml`)
  - [ ] Set up AWS credential secret reference
  - [ ] Add documentation for creating the AWS secret

- [ ] **Test providers chart**
  - [ ] Verify chart syntax with `helm lint`
  - [ ] Create test installation
  - [ ] Validate provider status with `kubectl get providers`
  - [ ] Troubleshoot any provider installation issues

## Phase 2: Core Infrastructure Resources

- [ ] **Create primary application chart structure**
  - [ ] Create `serverless-pdf-chat/` directory
  - [ ] Create `Chart.yaml` with dependency on providers chart
  - [ ] Create initial `values.yaml` with application settings
  - [ ] Create `templates/` directory
  - [ ] Add common helper functions in `_helpers.tpl`

- [ ] **Implement S3 bucket resource**
  - [ ] Create `templates/aws/s3.yaml`
  - [ ] Configure bucket with proper naming
  - [ ] Set up CORS configuration
  - [ ] Configure public access blocking
  - [ ] Enable HTTPS enforcement
  - [ ] Add metadata and references

- [ ] **Implement DynamoDB tables**
  - [ ] Create `templates/aws/dynamodb.yaml`
  - [ ] Define document table with proper key schema
  - [ ] Define memory table with session ID key
  - [ ] Configure billing mode (pay-per-request)
  - [ ] Add metadata and references

- [ ] **Implement SQS queue**
  - [ ] Create `templates/aws/sqs.yaml`
  - [ ] Configure embedding queue with proper timeout
  - [ ] Set message retention period
  - [ ] Add metadata and references

- [ ] **Test infrastructure resources**
  - [ ] Deploy chart with infrastructure resources only
  - [ ] Verify resource creation in AWS console
  - [ ] Validate resource properties and configuration
  - [ ] Test permissions and access

## Phase 3: Authentication and Security Resources

- [ ] **Implement Cognito resources**
  - [ ] Create `templates/aws/cognito.yaml`
  - [ ] Define user pool with proper attributes
  - [ ] Configure password policy
  - [ ] Set up email verification
  - [ ] Create user pool client
  - [ ] Add metadata and references

- [ ] **Implement IAM resources**
  - [ ] Create `templates/aws/iam.yaml`
  - [ ] Define Lambda execution role
  - [ ] Configure trust relationship for Lambda
  - [ ] Create policies for S3 access
  - [ ] Create policies for DynamoDB access
  - [ ] Create policies for SQS access
  - [ ] Create policies for Bedrock access
  - [ ] Add metadata and references

- [ ] **Test authentication setup**
  - [ ] Deploy chart with auth resources
  - [ ] Create test user in Cognito
  - [ ] Verify IAM role permissions
  - [ ] Test authentication flow

## Phase 4: Lambda Function Resources

- [ ] **Define Lambda function templates**
  - [ ] Create `templates/aws/lambda/` directory
  - [ ] Create template for upload trigger (`upload-trigger.yaml`)
  - [ ] Create template for presigned URL generation (`generate-presigned-url.yaml`)
  - [ ] Create template for embedding generation (`generate-embeddings.yaml`)
  - [ ] Create template for document retrieval (`get-document.yaml`)
  - [ ] Create template for document listing (`get-all-documents.yaml`)
  - [ ] Create template for document deletion (`delete-document.yaml`)
  - [ ] Create template for conversation management (`add-conversation.yaml`)
  - [ ] Create template for response generation (`generate-response.yaml`)

- [ ] **Configure Lambda function code**
  - [ ] Set up code packaging format (ZIP)
  - [ ] Define code source location
  - [ ] Configure Python runtime settings
  - [ ] Set memory and timeout per function
  - [ ] Configure environment variables

- [ ] **Configure Lambda permissions and roles**
  - [ ] Assign IAM execution role to functions
  - [ ] Configure resource-based policies
  - [ ] Set up cross-service permissions

- [ ] **Test Lambda functions**
  - [ ] Deploy chart with Lambda resources
  - [ ] Verify function creation in AWS console
  - [ ] Test function invocation
  - [ ] Validate environment variable configuration

## Phase 5: API Gateway Configuration

- [ ] **Create API Gateway resources**
  - [ ] Create `templates/aws/apigateway.yaml`
  - [ ] Define REST API with proper name and configuration
  - [ ] Configure CORS settings
  - [ ] Set up deployment stage
  - [ ] Add metadata and references

- [ ] **Define API routes and methods**
  - [ ] Create `templates/aws/apigateway-routes.yaml`
  - [ ] Configure route for generating presigned URLs
  - [ ] Configure route for document retrieval
  - [ ] Configure route for document listing
  - [ ] Configure route for conversation creation
  - [ ] Configure route for response generation
  - [ ] Configure route for document deletion
  - [ ] Set up Lambda integrations for each route

- [ ] **Set up API authentication**
  - [ ] Create `templates/aws/apigateway-authorizer.yaml`
  - [ ] Configure Cognito authorizer
  - [ ] Set up authorization scopes
  - [ ] Define protected routes

- [ ] **Configure custom domain (optional)**
  - [ ] Set up domain name in API Gateway
  - [ ] Configure base path mapping
  - [ ] Set up TLS certificate

- [ ] **Test API Gateway**
  - [ ] Deploy chart with API Gateway resources
  - [ ] Verify endpoint creation
  - [ ] Test API endpoints with authentication
  - [ ] Validate CORS functionality

## Phase 6: Event Triggers Configuration

- [ ] **Configure S3 event notifications**
  - [ ] Create `templates/aws/s3-notifications.yaml`
  - [ ] Set up trigger for PDF uploads
  - [ ] Configure event types and filters
  - [ ] Link to Lambda function

- [ ] **Set up Lambda permissions**
  - [ ] Create `templates/aws/lambda-permissions.yaml`
  - [ ] Configure permissions for API Gateway invocation
  - [ ] Configure permissions for S3 event triggers
  - [ ] Set up proper source ARNs

- [ ] **Test event triggers**
  - [ ] Deploy chart with trigger resources
  - [ ] Verify notification configuration
  - [ ] Test end-to-end flow with file upload
  - [ ] Validate event-driven processing

## Phase 7: Frontend Containerization

- [ ] **Create frontend Dockerfile**
  - [ ] Set up Node.js build environment
  - [ ] Configure dependency installation
  - [ ] Set up build process with environment variables
  - [ ] Create multi-stage build with Nginx
  - [ ] Configure Nginx for SPA routing

- [ ] **Create Kubernetes resources for frontend**
  - [ ] Create `templates/frontend/deployment.yaml`
  - [ ] Create `templates/frontend/service.yaml`
  - [ ] Create `templates/frontend/ingress.yaml`
  - [ ] Create `templates/frontend/configmap.yaml`

- [ ] **Configure frontend environment**
  - [ ] Set up API endpoint reference
  - [ ] Configure Cognito client details
  - [ ] Set up regional settings
  - [ ] Create environment variables

- [ ] **Set up frontend health and scaling**
  - [ ] Configure readiness probe
  - [ ] Configure liveness probe
  - [ ] Set up resource limits and requests
  - [ ] Configure horizontal scaling (optional)

- [ ] **Build and push frontend image**
  - [ ] Create CI pipeline for image building
  - [ ] Push image to container registry
  - [ ] Update image reference in values file

- [ ] **Test frontend deployment**
  - [ ] Deploy frontend-only resources
  - [ ] Verify container startup
  - [ ] Check service connectivity
  - [ ] Test ingress and TLS

## Phase 8: Supporting Kubernetes Resources

- [ ] **Create namespace resources**
  - [ ] Create `templates/namespace.yaml`
  - [ ] Configure namespace metadata and labels

- [ ] **Set up service account**
  - [ ] Create `templates/serviceaccount.yaml`
  - [ ] Configure proper annotations and permissions

- [ ] **Create configuration resources**
  - [ ] Create `templates/aws-references.yaml` for AWS resource references
  - [ ] Create `templates/frontend-secrets.yaml` for sensitive data

- [ ] **Test Kubernetes resources**
  - [ ] Deploy supporting resources
  - [ ] Verify proper creation and configuration
  - [ ] Check namespace isolation
  - [ ] Validate permissions

## Phase 9: Integration and End-to-End Testing

- [ ] **Configure frontend-to-API integration**
  - [ ] Update frontend to use API Gateway endpoint
  - [ ] Configure authentication flow
  - [ ] Test API connectivity from frontend

- [ ] **Test complete document workflow**
  - [ ] Test document upload functionality
  - [ ] Verify embedding generation
  - [ ] Test document retrieval
  - [ ] Validate conversation creation

- [ ] **Test conversation workflow**
  - [ ] Test question submission
  - [ ] Verify response generation
  - [ ] Test conversation memory
  - [ ] Validate context understanding

- [ ] **Performance testing**
  - [ ] Test Lambda function performance
  - [ ] Measure response times
  - [ ] Validate frontend responsiveness
  - [ ] Test under load conditions

- [ ] **Security testing**
  - [ ] Verify authentication requirements
  - [ ] Test authorization controls
  - [ ] Check for exposed credentials
  - [ ] Validate TLS configuration

## Phase 10: Packaging and Documentation

- [ ] **Package Helm charts**
  - [ ] Create chart archives
  - [ ] Generate chart dependencies
  - [ ] Update version information
  - [ ] Create chart repository (optional)

- [ ] **Create documentation**
  - [ ] Document chart values and configuration options
  - [ ] Create installation guide
  - [ ] Document AWS requirements and permissions
  - [ ] Create troubleshooting guide

- [ ] **Set up CI/CD pipeline**
  - [ ] Configure chart validation
  - [ ] Set up automated deployment
  - [ ] Create rollback procedures
  - [ ] Document pipeline usage

- [ ] **Finalize project**
  - [ ] Clean up temporary resources
  - [ ] Perform final validation
  - [ ] Update any remaining documentation
  - [ ] Create final release

## Reference Resources

- Crossplane AWS Provider Documentation
- AWS Lambda Documentation
- Helm Best Practices
- Kubernetes Documentation
- AWS API Gateway Documentation
- AWS Cognito Documentation
- Frontend React Documentation
