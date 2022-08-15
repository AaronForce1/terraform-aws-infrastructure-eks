##################################
####  Repository Secrets      ####
##################################
data "aws_ssm_parameter" "infrastructure_credentials_username" {
  for_each = {
    for secret in var.repository_secrets : secret.username => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.username
}

data "aws_ssm_parameter" "infrastructure_credentials_password" {
  for_each = {
    for secret in var.repository_secrets : secret.password => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.password
}

##################################
####  Credential Templates    ####
##################################
data "aws_ssm_parameter" "infrastructure_credentials_repository_username" {
  for_each = {
    for secret in var.credential_templates : secret.username => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.username
}

data "aws_ssm_parameter" "infrastructure_credentials_repository_password" {
  for_each = {
    for secret in var.credential_templates : secret.password => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.password
}

##################################
####  Registry Secrets        ####
##################################
data "aws_ssm_parameter" "infrastructure_credentials_registry_username" {
  for_each = {
    for secret in var.registry_secrets : secret.username => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.username
}

data "aws_ssm_parameter" "infrastructure_credentials_registry_password" {
  for_each = {
    for secret in var.registry_secrets : secret.password => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.password
}

data "aws_ssm_parameter" "infrastructure_credentials_registry_auth" {
  for_each = {
    for secret in var.registry_secrets : secret.auth => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.auth
}