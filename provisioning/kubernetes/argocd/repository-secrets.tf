data "aws_ssm_parameter" "argocd_infrastructure_ssh" {
  name = "/repository/kubernetes-infrastructure/ssh"
}

data "aws_ssm_parameter" "argocd_kubernetes_infrastructure_ssh" {
  name = "/repository/argocd-kubernetes-infrastructure/ssh"
}

data "aws_ssm_parameter" "argocd_application_ssh" {
  name = "/repository/kubernetes-application/ssh"
}

data "aws_ssm_parameter" "argocd_generic_helm_chart_registry_username" {
  name = "/repository/generic-helm-chart/username"
}

data "aws_ssm_parameter" "argocd_generic_helm_chart_registry_password" {
  name = "/repository/generic-helm-chart/password"
}

resource "kubernetes_secret" "argocd_infrastructure_ssh" {
  metadata {
    name      = "repository-infrastructure-ssh-key"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    sshPrivateKey = data.aws_ssm_parameter.argocd_infrastructure_ssh.value
  }
}

resource "kubernetes_secret" "argocd-kubernetes-infrastructure_ssh" {
  metadata {
    name      = "repository-argocd-kubernetes-infrastructure-ssh-key"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    sshPrivateKey = data.aws_ssm_parameter.argocd_kubernetes_infrastructure_ssh.value
  }
}

resource "kubernetes_secret" "argocd_application_ssh" {
  metadata {
    name      = "repository-application-ssh-key"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    sshPrivateKey = data.aws_ssm_parameter.argocd_application_ssh.value
  }
}

resource "kubernetes_secret" "argocd_helm_chart_registry" {
  metadata {
    name      = "repository-generic-helm-chart"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name     = "generic-helm-chart"
    url      = "https://gitlab.int.hextech.io/api/v4/projects/645/packages/helm/alpha"
    type     = "helm"
    username = data.aws_ssm_parameter.argocd_generic_helm_chart_registry_username.value
    password = data.aws_ssm_parameter.argocd_generic_helm_chart_registry_password.value
  }
}
