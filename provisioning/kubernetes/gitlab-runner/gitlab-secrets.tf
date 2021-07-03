resource "kubernetes_secret" "AWS" {

  metadata {
    name      = "s3access"
    namespace = "gitlab-runner"
  }

  data = {
    accesskey = module.iam_user.iam_access_key_id
    secretkey = module.iam_user.iam_access_key_secret
  }

  type = "generic"
}