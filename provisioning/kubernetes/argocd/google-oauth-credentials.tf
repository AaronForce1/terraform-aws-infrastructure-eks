resource "kubernetes_secret" "google-sso-service-account-secret" {
  metadata {
    name      = "argocd-google-groups-json"
    namespace = "argocd"
  }

  binary_data = {
    "argocdGoogleAuth.json" = data.aws_ssm_parameter.google_sso_service_account_secret.value
  }
}

resource "kubernetes_secret" "argocd_google_oauth_client_secret" {
  count = length(var.google_oauth_client_secret)

  metadata {
    name      = "argocd-google-oauth-${var.google_oauth_client_secret[count.index].name}"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" =  "argocd"
    }
  }

  data = { 
    client_secret = var.google_oauth_client_secret[count.index].secrets_store != "ssm" ? var.google_oauth_client_secret[count.index].client_secret : data.aws_ssm_parameter.google_sso_oauth_client_secret[var.google_oauth_client_secret[count.index].client_secret].value
  }
}
