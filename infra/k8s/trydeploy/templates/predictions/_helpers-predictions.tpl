{{/* The microservices name */}}
{{- define "trydeploy.predictions.name" -}}
{{- $predictionsName := .Values.microServices.predictions.name }}
{{- printf "%s-%s" .Chart.Name $predictionsName | trunc 63 | trimSuffix "-"}}
{{- end }}


{{/*
Common predictions labels
*/}}
{{- define "trydeploy.predictions.labels" -}}
helm.sh/chart: {{ include "trydeploy.chart" . }}
{{ include "trydeploy.predictions.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "trydeploy.predictions.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trydeploy.predictions.name" .}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Docker image */}}
{{- define "trydeploy.predictions.image" -}}
{{- with .Values.microServices.predictions.image }}
{{- printf "%s/%s/%s" $.Values.image.registry .repo .tag }}
{{- end }}
{{- end }}


{{/* HTTP service name */}}
{{- define "trydeploy.predictions.service.http.name" -}}
{{- with .Values.microServices.predictions }}
{{- printf "%s-%s" .name .services.http.port.name }}
{{- end }}
{{- end }}

{{/* RMQ service name */}}
{{- define "trydeploy.predictions.service.rmq.name" -}}
{{- with .Values.microServices.predictions }}
{{- printf "%s-%s" .name .services.rmq.port.name }}
{{- end }}
{{- end }}