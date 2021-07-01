{{/*
Expand the name of the chart.
*/}}
{{- define "fuseapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fuseapp.fullname" -}}
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
{{- define "fuseapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fuseapp.labels" -}}
helm.sh/chart: {{ include "fuseapp.chart" . }}
{{ include "fuseapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ include "fuseapp.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fuseapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fuseapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fuseapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fuseapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/***************** customized *****************/}}
{{/*
Name of EventListener
*/}}
{{- define "fuseapp.eventListenerName" -}}
{{ include "fuseapp.name" . }}-el
{{- end }}

{{/*
Name of Pipeline
*/}}
{{- define "fuseapp.pipelineName" -}}
{{ include "fuseapp.fullname" . }}
{{- end }}

{{/*
Name of TriggerTemplate
*/}}
{{- define "fuseapp.triggerTemplateName" -}}
{{ include "fuseapp.name" . }}-el
{{- end }}

{{/*
Name of Image
*/}}
{{- define "fuseapp.fullImageName" -}}
{{ .Values.app.image.registry }}/{{ .Release.Namespace }}/{{ .Chart.Name }}:{{ .Values.app.image.tag | default .Chart.AppVersion }}
{{- end }}
