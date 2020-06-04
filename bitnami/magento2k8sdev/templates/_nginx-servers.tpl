{{- define "common.nginx.servers.config" -}}
{{/* WARNING: Do not modify this file directly, it is auto-generated and any changes will be overwritten. */}}
server {
  listen "{{ .Values.global.monolith.service.nginxPort }}";
  server_name magento.magento2;
  set \$MAGE_ROOT {{.Values.global.monolith.volumeHostPath}}/magento2;
  {{- include "common.nginx.config" . | nindent 2 }}
}

{{- end -}}
