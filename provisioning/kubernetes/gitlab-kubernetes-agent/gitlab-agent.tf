resource "helm_release" "gitlab-k8s-agent" {
  name             = "gitlab-kubernetes-agent-${var.app_namespace}-${var.tfenv}"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  version          = var.chart_version
  namespace        = "gitlab-agent"
  create_namespace = true

  values = [
    <<-EOF
      config:
        kasAddress: ${var.gitlab_agent_url}
        token: ${var.gitlab_agent_secret}
        secretName: "gitlab-agent-token"
    EOF
  ]
}