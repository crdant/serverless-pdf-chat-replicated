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
{{- if .Values.commonLabels }}
{{- range $key, $value := .Values.commonLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "providers.annotations" -}}
{{- if .Values.commonAnnotations }}
{{- range $key, $value := .Values.commonAnnotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "providers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "providers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the runtime config name
*/}}
{{- define "providers.runtimeConfigName" -}}
{{ include "providers.fullname" . }}-runtime-config
{{- end }}

{{/*
Get the provider package URL
*/}}
{{- define "providers.packageUrl" -}}
{{- $provider := index .Values.aws.providers .providerName -}}
{{- $registry := .Values.global.images.registry | default .Values.aws.providers.registry -}}
{{- printf "%s/%s:%s" $registry $provider.package $provider.version -}}
{{- end }}

{{/*
Get the ServiceAccount name for jobs
*/}}
{{- define "providers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-jobs" (include "providers.fullname" .)) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the registry for jobs
*/}}
{{- define "providers.jobRegistry" -}}
{{- .Values.global.images.registry | default .Values.jobs.waitReadyJob.image.registry -}}
{{- end }}

{{/*
Get the registry for Kubernetes provider
*/}}
{{- define "providers.kubernetesRegistry" -}}
{{- .Values.global.images.registry | default .Values.kubernetes.provider.registry -}}
{{- end }}
