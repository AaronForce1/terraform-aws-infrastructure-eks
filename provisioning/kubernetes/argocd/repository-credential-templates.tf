resource "kubernetes_secret" "argocd_application_credential_template" {
  count = length(var.credential_templates)

  metadata {
    name      = "argocd-repo-creds-${var.credential_templates[count.index].name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
      "hextech.io/part-of"             = "terraform-aws-infrastructure-eks"
      "hextech.io/managed-by"          = "Terraform"
    }
  }

  data = {
    url      = var.credential_templates[count.index].url
    username = var.credential_templates[count.index].secrets_store != "ssm" ? var.credential_templates[count.index].username : data.aws_ssm_parameter.infrastructure_credentials_repository_username[var.credential_templates[count.index].username].value
    password = var.credential_templates[count.index].secrets_store != "ssm" ? var.credential_templates[count.index].password : data.aws_ssm_parameter.infrastructure_credentials_repository_password[var.credential_templates[count.index].password].value
  }
}
