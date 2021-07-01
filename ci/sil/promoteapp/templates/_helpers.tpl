{{/*
Expand the name of the chart.
*/}}
{{- define "promoteapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "promoteapp.fullname" -}}
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
{{- define "promoteapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "promoteapp.labels" -}}
helm.sh/chart: {{ include "promoteapp.chart" . }}
{{ include "promoteapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "promoteapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "promoteapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "promoteapp.serviceAccountName" -}}
{{- default (include "promoteapp.fullname" .) .Release.Name }}
{{- end }}

{{/***************** customized *****************/}}

{{/*
Name of Pipeline
*/}}
{{- define "promoteapp.pipelineName" -}}
{{ include "promoteapp.fullname" . }}
{{- end }}

{{/*
srcImageURL of Pipeline to Promote
*/}}
{{- define "promoteapp.srcImageURL" -}}
{{- if .Values.promote.source.imageUrl }}
{{- printf "%s" .Values.promote.source.imageUrl }}
{{- else }}
{{- printf "%s/%s/%s:%s" .Values.promote.source.registry .Values.promote.source.namespace .Values.promote.source.name .Values.promote.source.tag }}
{{- end }}
{{- end }}

{{/*
destImageURL of Pipeline to Promote
*/}}
{{- define "promoteapp.destImageURL" -}}
{{- if .Values.promote.destination.imageUrl }}
{{- printf "%s" .Values.promote.destination.imageUrl }}
{{- else }}
{{- printf "%s/%s/%s:%s" .Values.promote.destination.registry .Values.promote.destination.namespace .Values.promote.destination.name .Values.promote.destination.tag }}
{{- end }}
{{- end }}
