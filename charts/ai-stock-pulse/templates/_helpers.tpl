{{/*
Expand the name of the chart.
*/}}
{{- define "ai-stock-pulse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ai-stock-pulse.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Chart label (name-version).
*/}}
{{- define "ai-stock-pulse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-stock-pulse.labels" -}}
helm.sh/chart: {{ include "ai-stock-pulse.chart" . }}
app.kubernetes.io/name: {{ include "ai-stock-pulse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
In-cluster Postgres Service hostname.
*/}}
{{- define "ai-stock-pulse.postgresHost" -}}
{{- printf "%s-postgres" (include "ai-stock-pulse.fullname" .) }}
{{- end }}

{{/*
Secret that holds DB credentials and API tokens.
*/}}
{{- define "ai-stock-pulse.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- printf "%s-secrets" (include "ai-stock-pulse.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Postgres connection string consumed by the NestJS backend as DATABASE_URL.
*/}}
{{- define "ai-stock-pulse.databaseUrl" -}}
{{- $user := .Values.postgres.credentials.username | urlquery -}}
{{- $pass := .Values.postgres.credentials.password | urlquery -}}
{{- $host := include "ai-stock-pulse.postgresHost" . -}}
{{- $db := .Values.postgres.credentials.dbName -}}
{{- printf "postgres://%s:%s@%s:5432/%s" $user $pass $host $db -}}
{{- end }}
