{{/*
Define a reusable template for Lambda functions
*/}}
{{- define "serverless-pdf-chat.lambda-function" -}}
apiVersion: lambda.aws.upbound.io/v1beta1
kind: Function
metadata:
  name: {{ include "serverless-pdf-chat.fullname" . }}-{{ .functionName }}
  labels:
    {{- include "serverless-pdf-chat.labels" . | nindent 4 }}
spec:
  forProvider:
    region: {{ .Values.aws.region }}
    description: {{ .functionConfig.description | quote }}
    # Use container image instead of S3 code
    packageType: "Image"
    imageUri: {{ printf "%s/%s/%s:%s" 
                 .Values.images.registry 
                 .Values.images.repository 
                 .functionConfig.repository 
                 (default (default .Values.images.tag .functionConfig.tag) .Chart.AppVersion) }}
    timeout: {{ default .Values.aws.lambda.timeout .functionConfig.timeout }}
    memorySize: {{ default .Values.aws.lambda.memorySize .functionConfig.memorySize }}
    # Use the roleArn helper
    role: {{ include "serverless-pdf-chat.roleArn" (dict "account" .Values.aws.accountId "name" (default (printf "%s-lambda-role" (include "serverless-pdf-chat.fullname" .)) .Values.aws.iam.roles.lambdaRole.name)) }}
    
    # Environment variables
    environment:
      - variables:
          # Standard environment variables
          DOCUMENT_BUCKET: {{ include "serverless-pdf-chat.bucketName" . | quote }}
          DOCUMENT_TABLE: {{ include "serverless-pdf-chat.documentTableName" . | quote }}
          MEMORY_TABLE: {{ include "serverless-pdf-chat.memoryTableName" . | quote }}
          EMBEDDING_QUEUE: {{ include "serverless-pdf-chat.embeddingQueueName" . | quote }}
          EMBEDDING_MODEL_ID: {{ .Values.application.config.embeddingModelId | quote }}
          MODEL_ID: {{ .Values.application.config.modelId | quote }}
          REGION: {{ .Values.application.config.region | quote }}
          # Function-specific environment variables
          {{- if .functionConfig.environment }}
          {{- range $env := .functionConfig.environment }}
          {{- range $key, $value := $env }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
          {{- end }}
          {{- end }}
  providerConfigRef:
    name: {{ .Values.aws.providerConfigName }}
{{- end -}}
