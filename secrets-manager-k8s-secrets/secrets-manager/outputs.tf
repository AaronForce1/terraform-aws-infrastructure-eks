output "secret_arn" {
  value = aws_secretsmanager_secret.secrets.arn
}

output "latest_version_id" {
  value = aws_secretsmanager_secret_version.secrets_version.version_id
}
