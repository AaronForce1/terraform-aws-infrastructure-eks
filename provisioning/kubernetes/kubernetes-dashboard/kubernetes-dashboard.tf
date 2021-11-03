resource "helm_release" "kubernetes-dashboard" {
  depends_on = [kubernetes_namespace.kubernetes-dashboard]

  name             = "kubernetes-dashboard-${var.app_namespace}-${var.tfenv}"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  version          = "5.0.0"
  namespace        = "kubernetes-dashboard"
  create_namespace = false

  values = []
}

variable "app_namespace" {}
variable "tfenv" {}
