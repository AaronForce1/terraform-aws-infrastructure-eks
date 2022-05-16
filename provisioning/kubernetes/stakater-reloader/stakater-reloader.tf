resource "helm_release" "stakater-reloader" {
  name             = "stakater-reloader-${var.app_namespace}-${var.tfenv}"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  namespace        = "monitoring"
  create_namespace = false
}

variable "app_namespace" {}
variable "tfenv" {}
