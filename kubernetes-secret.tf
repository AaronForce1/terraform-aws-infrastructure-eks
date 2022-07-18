data "aws_ssm_parameter" "regcred_username" {
  for_each = { 
    for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred 
    if regcred.secrets_store == "ssm"
  }

  name = each.value.docker_username
}

data "aws_ssm_parameter" "regcred_password" {
  for_each = {
    for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred 
    if regcred.secrets_store == "ssm"
  }

  name = each.value.docker_password
}

resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred }

  metadata {
    name = each.value.name
    namespace = each.value.namespace
  }

  data = {
    ".dockerconfigjson" = sensitive(jsonencode({
      auths = {
        "${each.value.docker_server}" = {
          "username" = each.value.secrets_store != "ssm" ? each.value.docker_username : data.aws_ssm_parameter.regcred_username["${each.value.name}-${each.value.namespace}"].value
          "password" = each.value.secrets_store != "ssm" ? each.value.docker_password : data.aws_ssm_parameter.regcred_password["${each.value.name}-${each.value.namespace}"].value
          "email"    = each.value.docker_email
          "auth"     = base64encode("${each.value.secrets_store != "ssm" ? each.value.username : data.aws_ssm_parameter.regcred_username["${each.value.name}-${each.value.namespace}"].value}:${each.value.secrets_store != "ssm" ? each.value.docker_password : data.aws_ssm_parameter.regcred_password["${each.value.name}-${each.value.namespace}"].value}")
        }
      }
    }))
  }

  type = "kubernetes.io/dockerconfigjson"
}
