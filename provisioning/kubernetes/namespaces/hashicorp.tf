resource "kubernetes_namespace" "hashicorp" {
  count = var.helm_installations.vault_consul ? 1 : 0
  metadata {
    name = "hashicorp"
  }
}