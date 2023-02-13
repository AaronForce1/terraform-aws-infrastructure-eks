resource "kubernetes_namespace" "teleport" {
  metadata {
    name = "teleport"
  }
}