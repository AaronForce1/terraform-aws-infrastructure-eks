resource "cloudflare_tunnel" "tunnel" {
  account_id = var.account_id
  name       = var.tunnel_name
  secret     = base64encode(random_password.cloudflare_access_password.result)
}

resource "random_password" "cloudflare_access_password" {
  length           = 64
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "cloudflare_tunnel_route" "example" {
  depends_on = [cloudflare_tunnel.tunnel]
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id
  network    = var.vpc_network
  comment    = "Tunnel route for ${var.environment}"
}

resource "kubernetes_secret" "cloudflare_credentials" {

  metadata {
    name = coalesce(var.tunnel_secret_name, "cloudflare-tunnel-secret")
    namespace = coalesce(var.tunnel_secret_namespace, "cloudflare")
    labels = merge(
      {
        "app.kubernetes.io/part-of" = "cloudflare"
      }
    )
  }
  data = {
    tunnelToken : cloudflare_tunnel.tunnel.tunnel_token
  }
  type = "Opaque"
}

output "token" {
  value = cloudflare_tunnel.tunnel.tunnel_token
}
