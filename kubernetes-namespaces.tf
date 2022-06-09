resource "kubernetes_namespace" "cluster" {
  depends_on = [module.eks]
  for_each   = toset(local.namespaces)

  metadata {
    labels = {
      name              = each.key
      "Terraform"       = true
      "eks/name"        = local.name_prefix
      "eks/environment" = var.tfenv
    }
    name = each.key
  }
}