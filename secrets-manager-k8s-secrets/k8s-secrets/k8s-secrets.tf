
data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = var.secrets_manager_secret_arn
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)
}

resource "kubernetes_secret" "secrets" {
  count = length(var.secrets)

  metadata {
    name      = var.secrets[count.index].name
    namespace = var.secrets[count.index].namespace
  }

  data = var.secrets[count.index].values
}
