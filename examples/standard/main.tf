module "infrastructure-terraform-eks" {
  source  = "../.."

  aws_region = var.aws_region

  app_namespace = "cluster"
  tfenv  = "prod"
  cluster_version = "1.21"
  helm_installations = {
    gitlab_runner = false
    vault_consul  = true
    ingress       = true
    elasticstack  = true
    grafana       = true
  }
  billingcustomer = "me"
  root_domain_name  = "tech.google.com"
  map_users = []
  google_clientID = "var.google_clientID"
  google_clientSecret = "var.google_clientSecret"
  google_authDomain = "google.com"
  create_launch_template = true
  enable_aws_vault_unseal = true
  cluster_endpoint_public_access_cidrs = [
    "0.0.0.0/0"
  ]

  managed_node_groups = [
    {
      name = "primary"
      desired_capacity = 6
      max_capacity = 6
      min_capacity = 6
      instance_type = "m5a.xlarge"
      key_name = ""
      public_ip = false
      create_launch_template = false
      disk_size = 50
      taints = []
      subnet_selections = {
        public = false
        private = true
      }
    }
  ]

  nat_gateway_custom_configuration = {
    enable_dns_hostnames              = true
    enable_nat_gateway                = true
    enable_vpn_gateway                = false
    enabled                           = true
    one_nat_gateway_per_az            = true
    propagate_public_route_tables_vgw = false
    single_nat_gateway                = false
  }
}