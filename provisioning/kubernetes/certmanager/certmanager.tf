resource "helm_release" "certmanager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.2.0"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}
