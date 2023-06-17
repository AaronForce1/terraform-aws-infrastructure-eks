data "kubernetes_all_namespaces" "allns" {}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}
