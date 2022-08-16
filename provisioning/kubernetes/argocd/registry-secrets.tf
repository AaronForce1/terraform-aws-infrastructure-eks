resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in var.registry_secrets : "${regcred.name}-argocd" => regcred }

  metadata {
    name      = "registry-${each.value.name}"
    namespace = "argocd"
  }

  data = {
    ".dockerconfigjson" = sensitive(jsonencode({
      auths = {
        "${each.value.url}" = {
          "username" = each.value.secrets_store != "ssm" ? each.value.username : data.aws_ssm_parameter.infrastructure_credentials_registry_username[each.value.username].value
          "password" = each.value.secrets_store != "ssm" ? each.value.password : data.aws_ssm_parameter.infrastructure_credentials_registry_password[each.value.password].value
          "email"    = each.value.email
          "auth"     = base64encode("${each.value.secrets_store != "ssm" ? each.value.username : data.aws_ssm_parameter.infrastructure_credentials_registry_username[each.value.username].value}:${each.value.secrets_store != "ssm" ? each.value.password : data.aws_ssm_parameter.infrastructure_credentials_registry_password[each.value.password].value}")
        }
      }
    }))
  }

  type = "kubernetes.io/dockerconfigjson"
}