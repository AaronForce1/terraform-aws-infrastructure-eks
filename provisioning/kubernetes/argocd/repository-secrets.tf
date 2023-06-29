resource "kubernetes_secret" "argocd_application_repository_secrets" {
  for_each = {
    for repository_secret in var.repository_secrets : repository_secret.name => repository_secret
  }

  metadata {
    name      = "repository-${each.value.name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
      "hextrust.platform/part-of"      = "terraform-aws-infrastructure-eks"
      "hextrust.platform/managed-by"   = "Terraform"
    }
  }

  data = {
    name     = each.value.name
    url      = each.value.url
    type     = each.value.type
    username = each.value.secrets_store != "ssm" ? each.value.username : data.aws_ssm_parameter.infrastructure_credentials_username[each.value.username].value
    password = each.value.secrets_store != "ssm" ? each.value.password : data.aws_ssm_parameter.infrastructure_credentials_password[each.value.password].value
  }
}

resource "kubernetes_secret" "argocd_helm_envsubst_plugin_repositories" {
  count = coalesce(var.generate_plugin_repository_secret, false) ? 1 : 0

  metadata {
    name      = "argocd-helm-envsubst-plugin-repositories"
    namespace = "argocd"
    labels = {
      "hextrust.platform/part-of"    = "terraform-aws-infrastructure-eks"
      "hextrust.platform/managed-by" = "Terraform"
    }
  }

  data = {
    "repositories.yaml" = yamlencode(local.helmRepositoryYaml)
  }
}
