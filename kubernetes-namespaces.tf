resource "kubernetes_namespace" "cluster" {
  depends_on = [module.eks]
  for_each = {
    for namespace in var.custom_namespaces : namespace.name => namespace
  }
  metadata {
    labels = merge(
      {
        name              = each.value.name
        "Terraform"       = true
        "eks/name"        = local.name_prefix
        "eks/environment" = var.tfenv
      },
      try(each.value.labels, [])
    )
    annotations = try(each.value.annotations, [])
    name 	= each.value.name
  }
}
