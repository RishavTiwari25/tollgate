{{/*
Chart helpers. Every Helm chart carries roughly this file, and it is worth
understanding rather than copying: these are what keep resource names unique
per release and labels consistent across every object.
*/}}

{{- define "tollgate.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
fullname prefixes the release name, which is what lets two releases of this
chart coexist in one namespace. The 63-character truncation is not cosmetic:
63 is the maximum length of a DNS label, and a Service whose name exceeds it is
rejected by the API server with a validation error nobody enjoys reading.
*/}}
{{- define "tollgate.fullname" -}}
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

{{- define "tollgate.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
The full label set, on every object.
*/}}
{{- define "tollgate.labels" -}}
helm.sh/chart: {{ include "tollgate.chart" . }}
{{ include "tollgate.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: tollgate
{{- end }}

{{/*
Selector labels are a STRICT SUBSET of the labels above, and they must never
change after the first install.

A Deployment's spec.selector is IMMUTABLE. Adding the chart version to the
selector — an easy mistake, since it looks like just another label — means
every `helm upgrade` that bumps the chart version tries to change an immutable
field, and the upgrade fails with a message that does not obviously say so.
That is why version and chart labels live in `labels` and never here.
*/}}
{{- define "tollgate.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tollgate.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "tollgate.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tollgate.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The Redis connection string: the bundled instance, an external one, or empty.
Empty means the gateway falls back to in-memory buckets — correct for a single
replica, and wrong for more than one, which the NOTES.txt warns about.
*/}}
{{- define "tollgate.redisUrl" -}}
{{- if .Values.redis.externalUrl }}
{{- .Values.redis.externalUrl }}
{{- else if .Values.redis.enabled }}
{{- printf "redis://%s-redis:6379" (include "tollgate.fullname" .) }}
{{- end }}
{{- end }}

{{- define "tollgate.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- printf "%s-secrets" (include "tollgate.fullname" .) }}
{{- end }}
{{- end }}
