resource "helm_release" "kubernetes-dashboard" {
  depends_on = [kubernetes_namespace.kubernetes-dashboard]

  name             = "kubernetes-dashboard-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  version          = "4.0.0"
  namespace        = "kubernetes-dashboard"
  create_namespace = false

  values = [
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v4.0.0.yaml"
}

locals {
  helmChartValues = {
  }
}

variable "app_namespace" {}
variable "tfenv" {}