resource "helm_release" "elasticstack-elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart               = "elasticsearch"
  version             = "v7.11.2"
  namespace           = "monitoring"

  values = [
    local_file.elasticsearch_values_yaml.content
  ]
}

resource "local_file" "elasticsearch_values_yaml" {
  content   = yamlencode(local.elasticsearch_helmChartValues)
  filename  = "${path.module}/src/elasticsearch.values.overrides.yaml"
}

locals {
  elasticsearch_helmChartValues = {
    "imagePullPolicy" = "Always",
    "volumeClaimTemplate" = {
      "resources": {
        "requests": {
          "storage": var.tfenv == "prod" ? "1000Gi" : "200Gi"
        }
      }
    }
  }
}
