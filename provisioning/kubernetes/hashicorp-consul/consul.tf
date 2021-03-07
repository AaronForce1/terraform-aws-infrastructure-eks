resource "helm_release" "consul" {
  name             = "consul-${var.app_namespace}-${var.tfenv}"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "consul"
  namespace        = "hashicorp"
  create_namespace = true

  values = [
    # file("${path.module}/values.v0.29.0.yaml")
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v0.29.0.yaml"
}

locals {
  helmChartValues = {
    "global" = {
      "domain" : "consul.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}",
      "datacenter" : "${var.app_name}-${var.app_namespace}-${var.tfenv}",
    },
    "server" = {
      "enabled" : true,
      "replicas" : 2
      # "bootstrapExpect": 1
    },
    "client" = {
      "enabled" : true
    },
    "ui" = {
      "enabled" : true
    },
    "syncCatalog" = {
      "enabled" : false,
      "toConsul" : false,
      "toK8S" : false

    },
    "connectInject" = {
      "enabled" : false,
      "default" : true
    },
    "controller" = {
      "enabled" : true
    }
  }
}

variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}