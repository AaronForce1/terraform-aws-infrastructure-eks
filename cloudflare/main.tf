module "cloudflare-tunnel" {
  source = "./cloudflare-tunnel"

  account_id              = var.cloudflare_account_id
  tunnel_name             = var.tunnel_name
  environment             = var.environment
  vpc_network             = var.vpc_network
  tunnel_secret_name      = var.tunnel_secret_name
  tunnel_secret_namespace = var.tunnel_secret_namespace
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

output "token" {
  value     = module.cloudflare-tunnel.token
  sensitive = true
}
