resource "helm_release" "elasticstack-filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  version    = "v7.15.0"
  namespace  = "monitoring"

  values = [
    <<-EOF
      imagePullPolicy: Always
      filebeatConfig:
        "filebeat.yml": ${local.filebeat_yml}
    EOF
  ]

  depends_on = [helm_release.elasticstack-logstash]
}

locals {
  filebeat_yml = <<EOF
      output.file.enabled: false
      setup.ilm.enabled: false
      setup.template.name: 'filebeat'
      setup.template.pattern: 'filebeat-*'
      filebeat.inputs:
      - type: container
        paths:
          - '/var/lib/docker/containers/*/*.log'
        json.keys_under_root: true
        json.ignore_decoding_error: true
      multiline.pattern: '^([0-9]{1,3}\.){3}[0-9]{1,3} \- \-|^ERROR [0-9]{4}-[0-9]{2}-[0-9]{2}|^INFO [0-9]{4}-[0-9]{2}-[0-9]{2}|^\[[0-9]{4}-[0-9]{2}-[0-9]{2}|^[0-9]{4}\/[0-9]{2}\/[0-9]{2}'
        multiline.negate: true
        multiline.match: after
        processors:
          - add_id:
              target_field: tie_breaker_id
          - add_cloud_metadata: ~
          - add_kubernetes_metadata: ~
          - decode_json_fields:
              fields: ["message"]
              when:
                equals:
                  kubernetes.container.namespace: "monitoring"
                  kubernetes.container.name: "modsecurity-log"

      output.logstash:
        hosts: ["logstash-logstash:5044"]
        index: "filebeat-%%{[agent.version]}-%%{+yyyy.MM.dd}"
    EOF
}
