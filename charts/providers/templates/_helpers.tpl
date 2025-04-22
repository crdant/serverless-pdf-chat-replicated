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
{{- if eq .scope "kubernetes" -}}
  {{- $registry := "" -}}
  {{- if and .Values.global .Values.global.images -}}
    {{- $registry = .Values.global.images.registry | default .Values.kubernetes.provider.registry -}}
  {{- else -}}
    {{- $registry = .Values.kubernetes.provider.registry -}}
  {{- end -}}
  {{- printf "%s/upbound/provider-kubernetes:%s" $registry .Values.kubernetes.provider.version -}}
{{- else -}}
  {{- $provider := index .Values.aws.providers .providerName -}}
  {{- $registry := "" -}}
  {{- if and .Values.global .Values.global.images -}}
    {{- $registry = .Values.global.images.registry | default .Values.aws.providers.registry -}}
  {{- else -}}
    {{- $registry = .Values.aws.providers.registry -}}
  {{- end -}}
  {{- printf "%s/upbound/%s:%s" $registry $provider.package $provider.version -}}
{{- end -}}
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
{{- if and .Values.global .Values.global.images -}}
  {{- .Values.global.images.registry | default .Values.jobs.waitReadyJob.image.registry -}}
{{- else -}}
  {{- .Values.jobs.waitReadyJob.image.registry -}}
{{- end -}}
{{- end }}

{{/*
Get the registry for Kubernetes provider
*/}}
{{- define "providers.kubernetesRegistry" -}}
{{- if and .Values.global .Values.global.images -}}
  {{- .Values.global.images.registry | default .Values.kubernetes.provider.registry -}}
{{- else -}}
  {{- .Values.kubernetes.provider.registry -}}
{{- end -}}
{{- end }}

{{/*
Get package pull secrets for Crossplane providers with proper precedence
global.images.pullSecrets takes precedence, then provider-specific pull secrets
*/}}
{{- define "providers.packagePullSecrets" -}}
{{- $pullSecrets := list -}}
{{- if and .root.Values.global .root.Values.global.images .root.Values.global.images.pullSecrets -}}
  {{- $pullSecrets = .root.Values.global.images.pullSecrets -}}
{{- else if and (eq .scope "aws") .root.Values.aws.providers.pullSecrets -}}
  {{- $pullSecrets = .root.Values.aws.providers.pullSecrets -}}
{{- else if and (eq .scope "kubernetes") .root.Values.kubernetes.imagePullSecrets -}}
  {{- $pullSecrets = .root.Values.kubernetes.imagePullSecrets -}}
{{- end -}}
{{- if $pullSecrets -}}
packagePullSecrets:
{{- range $pullSecrets }}
- name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Get image pull secrets for Kubernetes resources with proper precedence
*/}}
{{- define "providers.imagePullSecrets" -}}
{{- if and .Values.global .Values.global.images .Values.global.images.pullSecrets }}
imagePullSecrets:
{{- range .Values.global.images.pullSecrets }}
- name: {{ . }}
{{- end }}
{{- else if .Values.jobs.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.jobs.imagePullSecrets }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}
