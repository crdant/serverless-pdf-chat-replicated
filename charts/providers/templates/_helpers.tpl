{{/*
Expand the name of the chart.
*/}}
{{- define "providers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "providers.fullname" -}}
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
{{- define "providers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "providers.labels" -}}
helm.sh/chart: {{ include "providers.chart" . }}
{{ include "providers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "providers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "providers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the credentials secret name
*/}}
{{- define "providers.secretName" -}}
{{- .Values.aws.authentication.secret.name }}
{{- end }}

{{/*
Get the credentials secret namespace
*/}}
{{- define "providers.secretNamespace" -}}
{{- .Values.aws.authentication.secret.namespace }}
{{- end }}

{{/*
Get the credentials secret key
*/}}
{{- define "providers.secretKey" -}}
{{- "creds" }}
{{- end }}

{{/*
Get the provider package URL
*/}}
{{- define "providers.packageUrl" -}}
{{- $provider := index .Values.aws.providers .providerName -}}
{{- printf "%s/%s:%s" .Values.aws.providers.registry $provider.package $provider.version -}}
{{- end }}
