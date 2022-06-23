resource "kubernetes_manifest" "aws-auth" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "aws-auth"
      "namespace" = "kube-system"
    }
    "data" = {
      "mapUsers" = jsonencode(var.map_users)
      "mapAccounts" = jsonencode(var.map_accounts)
      "mapRoles" = jsonencode(local.aws_auth_roles)
    }
  }
}