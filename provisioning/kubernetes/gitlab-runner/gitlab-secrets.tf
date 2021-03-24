resource "kubernetes_secret" "AWS" {
  metadata {
    name = "s3access"
    namespace = "gitlab-runner"
  }

  data = {
    accesskey = var.gitlab_serviceaccount_id
    secretkey = var.gitlab_serviceaccount_secret
  }

  type = "generic"
}