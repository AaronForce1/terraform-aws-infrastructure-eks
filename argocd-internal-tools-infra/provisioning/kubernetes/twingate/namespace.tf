resource "kubernetes_namespace" "twingate" {
  metadata {
    name = "twingate"
  }
}