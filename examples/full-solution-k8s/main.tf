module "infrastructure-terraform-eks" {
  source  = "../.."

  aws_region = "ap-southeast-1"
  aws_secondary_region = var.aws_region_secondary

  app_namespace = "testing"
  tfenv  =  "basic"
  cluster_version = "1.21"
  helm_installations = {
    gitlab_runner = false
    vault_consul  = true
    ingress       = true
    elasticstack  = true
    grafana       = true
    argocd        = false
    dashboard     = true
  }
  helm_configurations = {
    vault_consul = {
      enable_aws_vault_unseal = true
    }
  }
  billingcustomer = "testing"
  cluster_root_domain = {
    name   = "testing.example.xyz"
    create = true
  }

  google_clientID = ""
  google_clientSecret = ""
  google_authDomain = "google.com"

  create_launch_template = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  map_users = [
    { "userarn" : "${data.aws_caller_identity.current.arn}", "username" : "admin", "groups" : ["system:masters"] },
  ]
  map_roles = [
    { "rolearn" : "${data.aws_caller_identity.current.arn}", "username" : "admin", "groups" : ["system:masters"] },
  ]

  eks_managed_node_groups = [
    {
      name                   = "test-application"
      ami_type               = "AL2_ARM_64"
      create_launch_template = true
      desired_capacity       = 6
      max_capacity           = 6
      min_capacity           = 6
      instance_types         = ["m6g.large"]
      capacity_type          = "ON_DEMAND"
      disk_size              = 30
      disk_encrypted         = true

      taints = []

      tags = {}
      subnet_selections = {
        public  = false
        private = true
      }
      public_ip = false
      key_name  = ""
    }
  ]
  
  tech_email = var.tech_email
}