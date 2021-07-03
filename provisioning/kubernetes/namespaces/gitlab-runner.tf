resource "kubernetes_namespace" "gitlab_runner" {
  count = var.helm_installations.gitlab_runner ? 1 : 0
  metadata {
    name = "gitlab-runner"
  }
}