resource "kubernetes_secret" "google-sso-service-account-secret" {
  metadata {
    name      = "argocd-google-groups-json"
    namespace = "argocd"
  }

  binary_data = {
    "argocdGoogleAuth.json" = data.aws_ssm_parameter.google_sso_service_account_secret.value
  }
}

resource "kubernetes_secret" "argocd_google_oauth" {
  count = length(var.argocd_google_oauth_template)
  metadata {
    name      = "argocd-google-${var.argocd_google_oauth_template[count.index].name}"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" =  "argocd"
    }
  }

  data = { 
    client_id = var.argocd_google_oauth_template[count.index].secrets_store != "ssm" ? var.argocd_google_oauth_template[count.index].client_id : data.aws_ssm_parameter.argocd_google_oauth_client_id[var.argocd_google_oauth_template[count.index].client_id].value
    client_secret = var.argocd_google_oauth_template[count.index].secrets_store != "ssm" ? var.argocd_google_oauth_template[count.index].client_secret : data.aws_ssm_parameter.argocd_google_oauth_client_secret[var.argocd_google_oauth_template[count.index].client_secret].value
  }
}

resource "kubernetes_secret" "grafana_google_oauth" {
  count = length(var.grafana_google_oauth_template)
  metadata {
    name      = "grafana-google-${var.argocd_google_oauth_template[count.index].name}"
    namespace = "grafana-stack"
  }

  data = { 
    client_id = var.grafana_google_oauth_template[count.index].secrets_store != "ssm" ? var.grafana_google_oauth_template[count.index].client_id : data.aws_ssm_parameter.grafana_google_oauth_client_id[var.grafana_google_oauth_template[count.index].client_id].value
    client_secret = var.grafana_google_oauth_template[count.index].secrets_store != "ssm" ? var.grafana_google_oauth_template[count.index].client_secret : data.aws_ssm_parameter.grafana_google_oauth_client_secret[var.grafana_google_oauth_template[count.index].client_secret].value
  }
}
