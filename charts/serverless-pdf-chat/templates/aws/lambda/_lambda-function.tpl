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
    name: {{ default (printf "%s-%s" (include "serverless-pdf-chat.fullname" .) .functionName) .functionConfig.name }}
    description: {{ .functionConfig.description | quote }}
    runtime: {{ .Values.aws.lambda.runtime }}
    handler: {{ .Values.aws.lambda.handler }}
    timeout: {{ default .Values.aws.lambda.timeout .functionConfig.timeout }}
    memorySize: {{ default .Values.aws.lambda.memorySize .functionConfig.memorySize }}
    role: {{ printf "arn:aws:iam::%s:role/%s" .Values.aws.accountId (default (printf "%s-lambda-role" (include "serverless-pdf-chat.fullname" .)) .Values.aws.iam.roles.lambdaRole.name) }}
    
    # Code configuration
    packageType: "Zip"
    s3Bucket: {{ default (printf "%s-documents" (include "serverless-pdf-chat.fullname" .)) .Values.aws.s3.documentBucketName }}
    s3Key: {{ printf "lambda/%s.zip" .functionName }}
    
    # Environment variables
    environment:
      - variables:
          {{- range $key, $value := .Values.aws.lambda.environment }}
          {{ $key }}: {{ tpl $value $ | quote }}
          {{- end }}
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
