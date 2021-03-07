resource "helm_release" "datadog-dashboard" {
  name             = "datadog-dashboard-${var.app_namespace}-${var.tfenv}"
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = "2.8.3"
  namespace        = "monitoring"
  create_namespace = false

  values = [
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v2.8.3.yaml"
}

locals {
  helmChartValues = {
    "datadog" = {
      "apiKey" : var.datadog_apikey,
      "clusterName" : "eks-${var.app_namespace}-${var.tfenv}",
      "site" : "datadoghq.eu",
      "logs" : {
        "enabled" : true
      }
    }
  }
}

variable "app_namespace" {}
variable "tfenv" {}
variable "datadog_apikey" {}