resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in coalesce(var.registry_secrets, []) : "${regcred.name}-argocd" => regcred }

  metadata {
    name      = "registry-${each.value.name}"
    namespace = "argocd"
    labels = merge(
      { "hextech.io/part-of"    = "terraform-aws-infrastructure-eks" },
      { "hextech.io/managed-by" = "Terraform" },
      try(each.value.labels, {})
    )
  }

  data = {
    ".dockerconfigjson" = sensitive(jsonencode({
      auths = {
        (each.value.url) = {
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
