resource "kubectl_manifest" "aws-auth" {
  yaml_body = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "aws-auth"
      "namespace" = "kube-system"
    }
    "data" = {
      "mapUsers"    = jsonencode(var.map_users)
      "mapAccounts" = jsonencode(var.map_accounts)
      "mapRoles"    = jsonencode(local.aws_auth_roles)
    }
  })
}