{{/*
Expand the name of the chart.
*/}}
{{- define "auth-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "auth-stack.fullname" -}}
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
{{- define "auth-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "auth-stack.labels" -}}
helm.sh/chart: {{ include "auth-stack.chart" . }}
{{ include "auth-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "auth-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "auth-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "auth-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "auth-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "auth-stack.ca" -}}
{{- genCA "auth-stack-ca" 365 -}}
{{- end -}}

{{/*
Generate certificates for custom-metrics api server 
*/}}
{{- define "auth-stack.gen-certs" -}}
{{- $altNames := list (printf "dex.%s" .Release.Namespace) (printf "dex.%s.svc" .Release.Namespace) -}}
{{- $ca := genCA "auth-stack-ca" 365 -}}
{{- $cert := genSignedCert (printf "dex.%s.svc.cluster.local" .Release.Namespace) nil $altNames 365 $ca -}}
cacert: {{ $ca.Cert | b64enc }}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}