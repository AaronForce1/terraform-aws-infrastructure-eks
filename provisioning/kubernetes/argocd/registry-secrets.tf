resource "kubernetes_secret" "argocd_application_registry_secrets" {
  count = length(var.registry_secrets)

  metadata {
    name      = "registry-${var.registry_secrets[count.index].name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "docker-registry"
    }
  }

  data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      "auths" : {
        "${var.registry_secrets[count.index].url}" : {
          "username" : "${var.registry_secrets[count.index].secrets_store != "ssm" ? var.registry_secrets[count.index].username : data.aws_ssm_parameter.infrastructure_credentials_registry_username[var.registry_secrets[count.index].username].value}",
          "password" : "${var.registry_secrets[count.index].secrets_store != "ssm" ? var.registry_secrets[count.index].password : data.aws_ssm_parameter.infrastructure_credentials_registry_password[var.registry_secrets[count.index].password].value}",
          "email" : "${var.registry_secrets[count.index].email}",
          "auth" : "${var.registry_secrets[count.index].secrets_store != "ssm" ? var.registry_secrets[count.index].auth : data.aws_ssm_parameter.infrastructure_credentials_registry_auth[var.registry_secrets[count.index].auth].value}",
        }
      }
    }))
  }

  type = "kubernetes.io/dockerconfigjson"
}