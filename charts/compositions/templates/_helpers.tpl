{{/*
Expand the name of the chart.
*/}}
{{- define "compositions.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "compositions.fullname" -}}
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
{{- define "compositions.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "compositions.labels" -}}
helm.sh/chart: {{ include "compositions.chart" . }}
{{ include "compositions.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- range $key, $value := .Values.commonLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "compositions.selectorLabels" -}}
app.kubernetes.io/name: {{ include "compositions.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Common annotations
*/}}
{{- define "compositions.annotations" -}}
{{- if .Values.commonAnnotations }}
{{- range $key, $value := .Values.commonAnnotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Get the ServiceAccount name for jobs
*/}}
{{- define "compositions.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-jobs" (include "compositions.fullname" .)) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the registry for jobs
*/}}
{{- define "compositions.jobRegistry" -}}
{{- .Values.global.images.registry | default .Values.jobs.waitForCompositionsJob.image.registry -}}
{{- end }}

{{/*
Get the credentials secret name
*/}}
{{- define "compositions.secretName" -}}
{{- .Values.aws.authentication.secret.name }}
{{- end }}

{{/*
Get the credentials secret namespace
*/}}
{{- define "compositions.secretNamespace" -}}
{{- .Values.aws.authentication.secret.namespace }}
{{- end }}

{{/*
Get the credentials secret key
*/}}
{{- define "compositions.secretKey" -}}
{{- "creds" }}
{{- end }}

{{/*
Get image pull secrets for jobs
*/}}
{{- define "compositions.imagePullSecrets" -}}
{{- $pullSecrets := list }}
{{- if .Values.global.images.pullSecrets }}
{{- $pullSecrets = .Values.global.images.pullSecrets }}
{{- else if .Values.jobs.waitForCompositionsJob.image.pullSecrets }}
{{- $pullSecrets = .Values.jobs.waitForCompositionsJob.image.pullSecrets }}
{{- end }}
{{- if $pullSecrets }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Get the runtime config name
*/}}
{{- define "compositions.runtimeConfigName" -}}
default
{{- end }}

{{/*
Get the provider package URL
*/}}
{{- define "compositions.packageUrl" -}}
{{- $provider := index .Values.aws.providers .providerName -}}
{{- printf "%s/%s:%s" .Values.aws.providers.registry $provider.package $provider.version -}}
{{- end }}
