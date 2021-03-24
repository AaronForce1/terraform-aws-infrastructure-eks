resource "helm_release" "elasticstack-filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart               = "filebeat"
  version             = "v7.11.2"
  namespace           = "monitoring"

  values = [
    local_file.filebeat_values_yaml.content
  ]

  depends_on = [helm_release.elasticstack-logstash]
}

resource "local_file" "filebeat_values_yaml" {
  content   = yamlencode(local.filebeat_helmChartValues)
  filename  = "${path.module}/src/filebeat.values.overrides.yaml"
}

locals {
  filebeat_helmChartValues = {
    "imagePullPolicy" = "Always",
    "filebeatConfig" = {
      "filebeat.yml": <<EOF
        filebeat.inputs:
        - type: container
          paths:
            - '/var/lib/docker/containers/*/*.log'

        output.logstash:
          hosts: ["logstash-logstash:5044"]
          index: "filebeat-%%{[agent.version]}-%%{+yyyy.MM.dd}"
      EOF
    }
  }
}
