resource "helm_release" "metrics-server" {
  name             = "metrics-server-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "monitoring"
  create_namespace = false
}

variable "app_namespace" {}
variable "tfenv" {}
