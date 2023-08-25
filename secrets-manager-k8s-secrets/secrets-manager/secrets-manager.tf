resource "aws_secretsmanager_secret_version" "secrets_version" {
  secret_id     = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode({ for secret in var.secrets : secret.name => merge({ namespace = secret.namespace }, secret.values) })
}

resource "aws_secretsmanager_secret" "secrets" {
  name       = var.secretsmanager_name
  kms_key_id = var.kms_key_arn
}
