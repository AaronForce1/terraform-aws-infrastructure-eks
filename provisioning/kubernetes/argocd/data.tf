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