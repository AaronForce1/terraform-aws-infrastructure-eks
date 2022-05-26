resource "helm_release" "certmanager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.chart_version
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

