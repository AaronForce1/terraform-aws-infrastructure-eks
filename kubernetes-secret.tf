data "aws_ssm_parameter" "regcred_username" {
  for_each = { 
    for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred 
  }
  

  name = each.value.docker_username_ssm_path
}

data "aws_ssm_parameter" "regcred_password" {
  for_each = {
    for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred 
  }

  name = each.value.docker_password_ssm_path
}

resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in var.registry_credentials: "${regcred.name}-${regcred.namespace}" => regcred }

  metadata {
    name = each.value.name
    namespace = each.value.namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${each.value.docker_server}" = {
          "username" = data.aws_ssm_parameter.regcred_username["${each.value.name}-${each.value.namespace}"].value
          "password" = data.aws_ssm_parameter.regcred_password["${each.value.name}-${each.value.namespace}"].value
          "email"    = each.value.docker_email
          "auth"     = base64encode("${each.value.docker_username_ssm_path}:${each.value.docker_password_ssm_path}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}