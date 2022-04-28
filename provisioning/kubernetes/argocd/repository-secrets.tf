data "aws_ssm_parameter" "argocd_ssh" {
  name = "/repository/ssh"
}

resource "kubernetes_secret" "argocd_ssh" {
  metadata {
    name      = "repository-ssh-key"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    sshPrivateKey = data.aws_ssm_parameter.argocd_ssh.value
  }
}