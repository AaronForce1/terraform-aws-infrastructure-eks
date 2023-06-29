###########################################################################
#### Kubernetes Secrets: Default                                       ####
###########################################################################
data "aws_ssm_parameter" "kubernetes_secret" {
  depends_on = [
    module.eks
  ]

  for_each = {
    for secret in var.kubernetes_secrets : "${secret.name}-${secret.namespace}" => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.secrets_store_name
}

resource "kubernetes_secret" "kubernetes_secret" {
  depends_on = [
    module.eks
  ]

  for_each = { for secret in coalesce(var.kubernetes_secrets, []) : "${secret.name}-${secret.namespace}" => secret }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = merge(
      {
        "hextech.io/part-of"    = "terraform-aws-infrastructure-eks"
        "hextech.io/managed-by" = "Terraform"
      },
      try(each.value.labels, [])
    )
  }
  data = each.value.secrets_store != "ssm" ? yamldecode(each.value.data) : yamldecode(data.aws_ssm_parameter.kubernetes_secret["${each.value.name}-${each.value.namespace}"].value)
  type = coalesce(each.value.type, "Opaque")
}

###########################################################################
#### Kubernetes Secrets: Regcred                                       ####
###########################################################################
data "aws_ssm_parameter" "regcred_username" {
  for_each = {
    for regcred in var.registry_credentials : "${regcred.name}-${regcred.namespace}" => regcred
    if regcred.secrets_store == "ssm"
  }

  name = each.value.docker_username
}

data "aws_ssm_parameter" "regcred_password" {
  for_each = {
    for regcred in var.registry_credentials : "${regcred.name}-${regcred.namespace}" => regcred
    if regcred.secrets_store == "ssm"
  }

  name = each.value.docker_password
}

resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in var.registry_credentials : "${regcred.name}-${regcred.namespace}" => regcred }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = {
      "hextech.io/part-of"    = "terraform-aws-infrastructure-eks"
      "hextech.io/managed-by" = "Terraform"
    }
  }

  data = {
    ".dockerconfigjson" = sensitive(jsonencode({
      auths = {
        (each.value.docker_server) = {
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
