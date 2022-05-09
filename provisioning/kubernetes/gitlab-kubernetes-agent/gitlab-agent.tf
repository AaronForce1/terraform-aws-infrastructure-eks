resource "helm_release" "gitlab-k8s-agent" {
  name             = "gitlab-kubernetes-agent-${var.app_namespace}-${var.tfenv}"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  version          = "v0.6.1"
  namespace        = "gitlab-agent"
  create_namespace = true

  values = [
    <<-EOF
      config:
      kasAddress: ${var.gitlab_agent_url}
      token: ${var.gitlab_agent_secret}
      secretName: "gitlab-agent-token"
      caCert: ${var.cluster_ca_certificate}
    EOF
  ]
}

variable "app_namespace" {}
variable "tfenv" {}
variable "gitlab_agent_url" {}
variable "gitlab_agent_secret" {}
variable "cluster_ca_certificate" {}