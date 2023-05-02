resource "kubernetes_namespace" "teleport" {
  count = length(var.teleport_installations) > 0 ? 1 : 0
  metadata {
    name = "teleport"
  }
}