resource "kubernetes_secret" "kubernetes_secret" {
  # for_each = {
  #   for token in twingate_connector_tokens.aws_connector_tokens : token.id => token
  # }

  count = var.connector_count
  metadata {
    name      = "twingate-credentials-${data.twingate_connector.connector[count.index].name}"
    namespace = "twingate"
    labels = merge(
      {
        "app.kubernetes.io/part-of" = "twingate"
      }
    )
  }
  data = {
    TWINGATE_ACCESS_TOKEN  = twingate_connector_tokens.aws_connector_tokens[count.index].access_token
    TWINGATE_REFRESH_TOKEN = twingate_connector_tokens.aws_connector_tokens[count.index].refresh_token
  }

  type = "Opaque"
}