{{/*
Expand the name of the chart.
*/}}
{{- define "serverless-pdf-chat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "serverless-pdf-chat.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "serverless-pdf-chat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "serverless-pdf-chat.labels" -}}
helm.sh/chart: {{ include "serverless-pdf-chat.chart" . }}
{{ include "serverless-pdf-chat.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "serverless-pdf-chat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "serverless-pdf-chat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create a resource name based on the global prefix, environment, and resource name
*/}}
{{- define "serverless-pdf-chat.resourceName" -}}
{{- $values := .Values -}}
{{- $name := .name -}}
{{- printf "%s-%s-%s" $values.global.namePrefix $values.global.environment $name -}}
{{- end -}}

{{/*
Generate the S3 bucket name with the same random suffix
*/}}
{{- define "serverless-pdf-chat.bucketName" -}}
{{- $randomSuffix := substr 0 8 (sha256sum (printf "%s-%s" .Release.Name .Release.Namespace)) -}}
{{- include "serverless-pdf-chat.resourceName" (dict "Values" .Values "name" "documents") }}-{{ $randomSuffix -}}
{{- end -}}

{{/*
Generate an ARN for a resource
Usage: {{ include "serverless-pdf-chat.arn" (dict "service" "s3" "region" .Values.aws.region "account" .Values.aws.accountId "resource" "my-bucket") }}
*/}}
{{- define "serverless-pdf-chat.arn" -}}
{{- $service := .service -}}
{{- $region := .region -}}
{{- $account := .account -}}
{{- $resource := .resource -}}
{{- if eq $service "s3" -}}
arn:aws:{{ $service }}:::{{ $resource }}
{{- else if eq $service "logs" -}}
arn:aws:{{ $service }}:*:*:{{ $resource }}
{{- else -}}
arn:aws:{{ $service }}:{{ $region }}:{{ $account }}:{{ $resource }}
{{- end -}}
{{- end -}}

{{/*
Generate an IAM role ARN
Usage: {{ include "serverless-pdf-chat.roleArn" (dict "account" .Values.aws.accountId "name" "my-role-name") }}
*/}}
{{- define "serverless-pdf-chat.roleArn" -}}
{{- $account := .account -}}
{{- $name := .name -}}
arn:aws:iam::{{ $account }}:role/{{ $name }}
{{- end -}}

{{/*
Common tags
*/}}
{{- define "serverless-pdf-chat.tags" -}}
app.kubernetes.io/name: {{ include "serverless-pdf-chat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "serverless-pdf-chat.chart" . }}
{{- if .Values.tags }}
{{- range $key, $value := .Values.tags }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Generate the DynamoDB document table name
*/}}
{{- define "serverless-pdf-chat.documentTableName" -}}
{{- default (include "serverless-pdf-chat.resourceName" (dict "Values" .Values "name" "documents")) .Values.aws.dynamodb.documentTable.name -}}
{{- end -}}

{{/*
Generate the DynamoDB memory table name
*/}}
{{- define "serverless-pdf-chat.memoryTableName" -}}
{{- default (include "serverless-pdf-chat.resourceName" (dict "Values" .Values "name" "memory")) .Values.aws.dynamodb.memoryTable.name -}}
{{- end -}}

{{/*
Generate the SQS embedding queue name
*/}}
{{- define "serverless-pdf-chat.embeddingQueueName" -}}
{{- default (include "serverless-pdf-chat.resourceName" (dict "Values" .Values "name" "embedding")) .Values.aws.sqs.embeddingQueue.name -}}
{{- end -}}
