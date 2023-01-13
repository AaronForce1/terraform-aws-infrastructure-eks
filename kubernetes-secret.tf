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
        "app.kubernetes.io/part-of" = each.value.namespace
      },
      coalesce(each.value.labels, [])
    )
  }
  binary_data = {
    "data" = each.value.secrets_store != "ssm" ? each.value.data : data.aws_ssm_parameter.kubernetes_secret["${each.value.name}-${each.value.namespace}"].value
  }
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

##############################################################################################
#### Kubernetes Secret: Client Id Secret Google Service Account Postgres DB Credentials   ####
##############################################################################################
data "aws_ssm_parameter" "google_sso_service_account_secret" {
  for_each = {
    for secret in coalesce(var.google_service_account, []) : secret.data => secret
    if secret.secrets_store == "ssm"
  }
  name = each.value.data
}

data "aws_ssm_parameter" "infrastructure_client_id" {
  for_each = {
    for secret in coalesce(var.infrastructure_client_id_secret, []) : secret.client_id => secret
    if secret.secrets_store == "ssm"
  }
  name = each.value.client_id
}

data "aws_ssm_parameter" "infrastructure_client_secret" {
  for_each = {
    for secret in coalesce(var.infrastructure_client_id_secret, []) : secret.client_secret => secret
    if secret.secrets_store == "ssm"
  }
  name = each.value.client_secret
}

data "aws_ssm_parameter" "db_password" {
  for_each = {
    for secret in coalesce(var.db_credentials, []) : secret.password => secret
    if secret.secrets_store == "ssm"
  }
  name = each.value.password
}

data "aws_ssm_parameter" "db_postgres_password" {
  for_each = {
    for secret in coalesce(var.db_credentials, []) : secret.postgres-password => secret
    if secret.secrets_store == "ssm"
  }
  name = each.value.postgres-password
}

resource "kubernetes_secret" "google-sso-service-account-secret" {
  for_each = { for secret in coalesce(var.google_service_account, []) : "${secret.name}-${secret.namespace}" => secret }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = merge(
      {
        "app.kubernetes.io/part-of" = each.value.namespace
      },
    )
  }
  binary_data = {
    "data" = each.value.secrets_store != "ssm" ? each.value.data : data.aws_ssm_parameter.google_sso_service_account_secret[each.value.data].value
  }
  type = coalesce(each.value.type, "Opaque")
}

resource "kubernetes_secret" "infrastructure_client_id_secret" {
  for_each = { for secret in coalesce(var.infrastructure_client_id_secret, []) : "${secret.name}-${secret.namespace}" => secret }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = merge(
      {
        "app.kubernetes.io/part-of" = each.value.namespace
      },
    )
  }
  data = {
    client_id     = each.value.secrets_store != "ssm" ? each.value.client_id : data.aws_ssm_parameter.infrastructure_client_id[each.value.client_id].value
    client_secret = each.value.secrets_store != "ssm" ? each.value.client_secret : data.aws_ssm_parameter.infrastructure_client_secret[each.value.client_secret].value
  }
  type = coalesce(each.value.type, "Opaque")
}

resource "kubernetes_secret" "postgres_db_credentials" {
  for_each = { for secret in coalesce(var.db_credentials, []) : "${secret.name}-${secret.namespace}" => secret }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = merge(
      {
        "app.kubernetes.io/part-of" = each.value.namespace
      },
    )
  }
  data = {
    postgres-password = each.value.secrets_store != "ssm" ? each.value.postgres-password : data.aws_ssm_parameter.db_postgres_password[each.value.postgres-password].value
    password          = each.value.secrets_store != "ssm" ? each.value.password : data.aws_ssm_parameter.db_password[each.value.password].value
  }
  type = coalesce(each.value.type, "Opaque")
}
