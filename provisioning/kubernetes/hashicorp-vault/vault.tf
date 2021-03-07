resource "helm_release" "vault" {
  name             = "vault-${var.app_namespace}-${var.tfenv}"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "hashicorp"
  create_namespace = false

  values = [
    # file("${path.module}/values.v0.7.0.yaml")
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v0.9.0.yaml"
}

locals {
  helmChartValues = {
    "metrics" = {
      "enabled" : true
    },
    "server" = {
      "ingress" = {
        "enabled" : true,
        "annotations" : {
          "kubernetes.io/ingress.class" : "nginx"
          "cert-manager.io/cluster-issuer" : "letsencrypt-prod"
        },
        "hosts" : [{
          "host" : "vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}",
          "paths" : ["/"]
        }],
        "tls" : [{
          "secretName" : "vault-ing-tls",
          "hosts" : ["vault.${var.app_namespace}-${var.tfenv}.${var.root_domain_name}"]
        }]
      },
      "ha" = {
        "enabled" : true,
        "replicas" : 2
      }
    }
  }
}

variable "app_namespace" {}
variable "tfenv" {}
variable "root_domain_name" {}
variable "app_name" {}