output "kubernetes_secrets" {
  value = {
    for idx, secret in kubernetes_secret.secrets : idx => {
      namespace = secret.metadata[0].namespace
      data      = secret.data
    }
  }
}
