resource "kubernetes_secret" "AWS" {
  metadata {
    name      = "gitlab-runner-eks"
    namespace = "gitlab-runner"
  }

  data = {
    username = var.gitlab_serviceaccount_id
    password = var.gitlab_serviceaccount_secret
  }

  type = "generic"
}