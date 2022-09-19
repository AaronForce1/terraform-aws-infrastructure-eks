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
    for secret in coalesce(var.registry_secrets, []) : secret.username => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.username
}

data "aws_ssm_parameter" "infrastructure_credentials_registry_password" {
  for_each = {
    for secret in coalesce(var.registry_secrets, []) : secret.password => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.password
}

##################################
####    Google SSO Token      ####
##################################
data "aws_ssm_parameter" "google_sso_service_account_secret" {
   name = "/argocd/google-sso-service-account"
}

data "aws_ssm_parameter" "google_sso_oauth_client_secret" {
  for_each = {
    for secret in var.google_oauth_client_secret : secret.client_secret => secret
    if secret.secrets_store == "ssm"
  }

  name = each.value.client_secret
} 
