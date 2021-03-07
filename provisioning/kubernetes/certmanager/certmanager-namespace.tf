resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}