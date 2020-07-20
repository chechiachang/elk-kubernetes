{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "statefulset.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.fullname" -}}
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
{{- define "elasticsearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "elasticsearch.labels" -}}
app.kubernetes.io/name: {{ include "elasticsearch.name" . }}
helm.sh/chart: {{ include "elasticsearch.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "elasticsearch.matchLabels" -}}
app.kubernetes.io/name: {{ include "elasticsearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return the proper ES image name
*/}}
{{- define "elasticsearch.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
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
Create a default fully qualified master name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.master.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.master.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified ingest name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.ingest.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.ingest.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified coordinating name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.coordinating.fullname" -}}
{{- if .Values.global.kibanaEnabled -}}
{{- printf "%s-%s" .Release.Name .Values.global.coordinating.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.global.coordinating.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the hostname of every ElasticSearch seed node
*/}}
{{- define "elasticsearch.hosts" -}}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $releaseNamespace := .Release.Namespace }}
{{- $masterFullname := include "elasticsearch.master.fullname" . }}
{{- $coordinatingFullname := include "elasticsearch.coordinating.fullname" . }}
{{- $dataFullname := include "elasticsearch.data.fullname" . }}
{{- $ingestFullname := include "elasticsearch.ingest.fullname" . }}
{{- $masterFullname }}.{{ $releaseNamespace }}.svc.{{ $clusterDomain }},
{{- $coordinatingFullname }}.{{ $releaseNamespace }}.svc.{{ $clusterDomain }},
{{- $dataFullname }}.{{ $releaseNamespace }}.svc.{{ $clusterDomain }},
{{- if .Values.ingest.enabled }}
{{- $ingestFullname }}.{{ $releaseNamespace }}.svc.{{ $clusterDomain }},
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified data name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.data.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.data.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{ template "elasticsearch.initScriptsSecret" . }}
{{/*
Get the initialization scripts volume name.
*/}}
{{- define "elasticsearch.initScripts" -}}
{{- printf "%s-init-scripts" (include "elasticsearch.fullname" .) -}}
{{- end -}}

{{ template "elasticsearch.initScriptsCM" . }}
{{/*
Get the initialization scripts ConfigMap name.
*/}}
{{- define "elasticsearch.initScriptsCM" -}}
{{- printf "%s" .Values.initScriptsCM -}}
{{- end -}}

{{ template "elasticsearch.initScriptsSecret" . }}
{{/*
Get the initialization scripts Secret name.
*/}}
{{- define "elasticsearch.initScriptsSecret" -}}
{{- printf "%s" .Values.initScriptsSecret -}}
{{- end -}}

{{/*
 Create the name of the master service account to use
 */}}
{{- define "elasticsearch.master.serviceAccountName" -}}
{{- if .Values.master.serviceAccount.create -}}
    {{ default (include "elasticsearch.master.fullname" .) .Values.master.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.master.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the coordinating-only service account to use
 */}}
{{- define "elasticsearch.coordinating.serviceAccountName" -}}
{{- if .Values.coordinating.serviceAccount.create -}}
    {{ default (include "elasticsearch.coordinating.fullname" .) .Values.coordinating.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.coordinating.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the data service account to use
 */}}
{{- define "elasticsearch.data.serviceAccountName" -}}
{{- if .Values.data.serviceAccount.create -}}
    {{ default (include "elasticsearch.data.fullname" .) .Values.data.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.data.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.metrics.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.metrics.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper ES exporter image name
*/}}
{{- define "elasticsearch.metrics.image" -}}
{{- $registryName := .Values.metrics.image.registry -}}
{{- $repositoryName := .Values.metrics.image.repository -}}
{{- $tag := .Values.metrics.image.tag | toString -}}
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
Return the proper sysctl image name
*/}}
{{- define "elasticsearch.sysctl.image" -}}
{{- $registryName := .Values.sysctlImage.registry -}}
{{- $repositoryName := .Values.sysctlImage.repository -}}
{{- $tag := .Values.sysctlImage.tag | toString -}}
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
{{- define "elasticsearch.imagePullSecrets" -}}
{{- if .Values.global }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- else }}
{{- $imagePullSecrets := coalesce .Values.image.pullSecrets .Values.metrics.image.pullSecrets .Values.curator.image.pullSecrets .Values.sysctlImage.pullSecrets .Values.volumePermissions.image.pullSecrets -}}
{{- if $imagePullSecrets }}
imagePullSecrets:
{{- range $imagePullSecrets }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "elasticsearch.volumePermissions.image" -}}
{{- $registryName := .Values.volumePermissions.image.registry -}}
{{- $repositoryName := .Values.volumePermissions.image.repository -}}
{{- $tag := .Values.volumePermissions.image.tag | toString -}}
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
Return the proper Storage Class
Usage:
{{ include "elasticsearch.storageClass" (dict "global" .Values.global "local" .Values.master) }}
*/}}
{{- define "elasticsearch.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- if (eq "-" .global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .local.persistence.storageClass -}}
              {{- if (eq "-" .local.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .local.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .local.persistence.storageClass -}}
        {{- if (eq "-" .local.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .local.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob APIs.
*/}}
{{- define "cronjob.apiVersion" -}}
{{- if semverCompare "< 1.8-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "batch/v2alpha1" }}
{{- else if semverCompare ">=1.8-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "batch/v1beta1" }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for podsecuritypolicy.
*/}}
{{- define "podsecuritypolicy.apiVersion" -}}
{{- if semverCompare "<1.10-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "elasticsearch.curator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}-curator
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "elasticsearch.curator.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.curator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "elasticsearch.curator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "elasticsearch.curator.serviceAccountName" -}}
{{- if .Values.curator.serviceAccount.create -}}
    {{ default (include "elasticsearch.curator.fullname" .) .Values.curator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.curator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper ES curator image name
*/}}
{{- define "elasticsearch.curator.image" -}}
{{- $registryName := .Values.curator.image.registry -}}
{{- $repositoryName := .Values.curator.image.repository -}}
{{- $tag := .Values.curator.image.tag | toString -}}
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
Renders a value that contains template.
Usage:
{{ include "elasticsearch.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "elasticsearch.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
