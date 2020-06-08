{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "my-nginx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "my-nginx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-nginx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "my-nginx.labels" -}}
helm.sh/chart: {{ include "my-nginx.chart" . }}
{{ include "my-nginx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "my-nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-nginx.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "my-nginx.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Return the custom NGINX server block configmap.
*/}}
{{- define "nginx.serverBlockConfigmapName" -}}
{{- if .Values.existingServerBlockConfigmap -}}
    {{- printf "%s" (tpl .Values.existingServerBlockConfigmap $) -}}
{{- else -}}
    {{- printf "%s-server-block" (include "my-nginx.fullname" .) -}}
{{- end -}}
{{- end -}}


{{/*
Return true if a static site should be mounted in the NGINX container
*/}}
{{- define "nginx.useStaticSite" -}}
{{- if or .Values.cloneStaticSiteFromGit.enabled .Values.staticSiteConfigmap .Values.staticSitePVC }}
    {- true -}}
{{- end -}}
{{- end -}}


{{/*
Return the volume to use to mount the static site in the NGINX container
*/}}
{{- define "nginx.staticSiteVolume" -}}
{{- if .Values.cloneStaticSiteFromGit.enabled }}
emptyDir: {}
{{- else if .Values.staticSiteConfigmap }}
configMap:
  name: {{ .Values.staticSiteConfigmap }}
{{- else if .Values.staticSitePVC }}
persistentVolumeClaim:
  claimName: {{ .Values.staticSitePVC }}
{{- end }}
{{- end -}}


{{/*
Return the proper Git image name
*/}}
{{- define "cloneStaticSiteFromGit.image" -}}
{{- $registryName := .Values.cloneStaticSiteFromGit.image.registry -}}
{{- $repositoryName := .Values.cloneStaticSiteFromGit.image.repository -}}
{{- $tag := .Values.cloneStaticSiteFromGit.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "nginx.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets .Values.cloneStaticSiteFromGit.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.cloneStaticSiteFromGit.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets .Values.cloneStaticSiteFromGit.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.cloneStaticSiteFromGit.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}




