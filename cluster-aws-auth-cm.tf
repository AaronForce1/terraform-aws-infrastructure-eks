resource "kubectl_manifest" "aws-auth" {
  yaml_body = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "name"      = "aws-auth"
      "namespace" = "kube-system"
    }
    "data" = {
      "mapUsers"    = yamlencode(var.map_users)
      "mapAccounts" = yamlencode(var.map_accounts)
      "mapRoles"    = yamlencode(concat(local.aws_auth_roles, var.map_roles))
    }
  })
}