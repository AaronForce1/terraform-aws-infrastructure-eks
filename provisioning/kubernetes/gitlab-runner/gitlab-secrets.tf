resource "kubernetes_secret" "AWS" {
  count = var.gitlab_runner_storage_type == "S3" ? 1 : 0

  metadata {
    name      = "s3access"
    namespace = "gitlab-runner"
  }

  data = {
    accesskey = var.gitlab_serviceaccount_id
    secretkey = var.gitlab_serviceaccount_secret
  }

  type = "generic"
}