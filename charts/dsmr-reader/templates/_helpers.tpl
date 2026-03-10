{{/*
Expand the name of the chart.
*/}}
{{- define "dsmr-reader.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dsmr-reader.fullname" -}}
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
{{- define "dsmr-reader.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dsmr-reader.labels" -}}
helm.sh/chart: {{ include "dsmr-reader.chart" . }}
{{ include "dsmr-reader.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dsmr-reader.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dsmr-reader.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dsmr-reader.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dsmr-reader.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL hostname.
When the bundled subchart is enabled the hostname follows the Bitnami naming
convention: <release>-postgresql.
Otherwise the externalDatabase.host value is used.
*/}}
{{- define "dsmr-reader.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- required "externalDatabase.host is required when postgresql.enabled is false" .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port.
*/}}
{{- define "dsmr-reader.databasePort" -}}
{{- if .Values.postgresql.enabled }}
{{- print "5432" }}
{{- else }}
{{- .Values.externalDatabase.port | toString }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name.
*/}}
{{- define "dsmr-reader.databaseName" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username.
*/}}
{{- define "dsmr-reader.databaseUser" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.externalDatabase.username }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds the DSMR Reader application credentials
(admin password + Django secret key).
*/}}
{{- define "dsmr-reader.credentialsSecretName" -}}
{{- if .Values.dsmr.credentials.existingSecret }}
{{- .Values.dsmr.credentials.existingSecret }}
{{- else }}
{{- printf "%s-credentials" (include "dsmr-reader.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds the database password for DSMR Reader.
When using the bundled postgresql subchart this is the bitnami-generated secret;
when using an external database it can be an existing secret.
*/}}
{{- define "dsmr-reader.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
{{- if .Values.postgresql.auth.existingSecret }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- else }}
{{- if .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-externaldb" (include "dsmr-reader.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Key inside the database secret that holds the password.
bitnami/postgresql auto-created Secret uses "password" as the user-password
key. When an existingSecret is supplied the key is read from secretKeys.userPasswordKey.
*/}}
{{- define "dsmr-reader.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.secretKeys.userPasswordKey | default "password" }}
{{- else }}
{{- .Values.externalDatabase.existingSecretPasswordKey | default "password" }}
{{- end }}
{{- end }}

{{/*
Name of the PersistentVolumeClaim for backups.
*/}}
{{- define "dsmr-reader.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- printf "%s-backups" (include "dsmr-reader.fullname" .) }}
{{- end }}
{{- end }}
