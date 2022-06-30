resource "kubernetes_secret" "argocd_application_credential_template" {
  count = length(var.repository_secrets)

  metadata {
    name      = "repository-${var.repository_secrets[count.index].name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name     = var.repository_secrets[count.index].name
    url      = var.repository_secrets[count.index].url
    type     = var.repository_secrets[count.index].type
    username = var.repository_secrets[count.index].secrets_store != "ssm" ? var.repository_secrets[count.index].username : data.aws_ssm_parameter.infrastructure_credentials_username[var.repository_secrets[count.index].username].value
    password = var.repository_secrets[count.index].secrets_store != "ssm" ? var.repository_secrets[count.index].password : data.aws_ssm_parameter.infrastructure_credentials_password[var.repository_secrets[count.index].password].value
  }
}