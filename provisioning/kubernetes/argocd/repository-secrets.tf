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

locals {
  repositorySecret = {
    for secret in var.repository_secrets: "value" => secret
    if secret.name == var.plugin_repository_secret.repository_secret_name
  }
}

resource "kubernetes_secret" "argocd_helm_envsubst_plugin_repositories" {
  count = var.plugin_repository_secret.enabled? 1: 0 

  metadata {
    name = "argocd-helm-envsubst-plugin-repositories"
    namespace = "argocd"
  }
  
  data = {
    "repositories.yaml" = <<-EOF
      apiVersion: ""
      generated: "0001-01-01T00:00:00Z"
      repositories:
      - caFile: ""
        certFile: ""
        insecure_skip_tls_verify: false
        keyFile: ""
        pass_credentials_all: false
        name: ${local.repositorySecret.value.name}
        url: ${local.repositorySecret.value.url}
        username: ${data.aws_ssm_parameter.infrastructure_credentials_username[local.repositorySecret.value.username].value}
        password: ${data.aws_ssm_parameter.infrastructure_credentials_password[local.repositorySecret.value.password].value}
    EOF
  }
}
