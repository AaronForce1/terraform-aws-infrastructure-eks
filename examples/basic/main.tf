module "infrastructure-terraform-eks" {
  source  = "../.."

  aws_region = "ap-southeast-1"

  app_namespace = "testing"
  tfenv  =  "basic"
  cluster_version = "1.21"
  helm_installations = {
    gitlab_runner = false
    vault_consul  = false
    ingress       = true
    elasticstack  = false
    grafana       = false
  }
  billingcustomer = "testing"
  cluster_root_domain.name  = "testing.example.com"

  google_clientID = ""
  google_clientSecret = ""
  google_authDomain = "google.com"

  create_launch_template = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  managed_node_groups = [
    {
      name = "primary"
      desired_capacity = 1
      max_capacity = 1
      min_capacity = 1
      instance_type = "m6g.large"
      ami_type = "AL2_ARM_64"
      key_name = ""
      public_ip = false
      create_launch_template = false
      disk_size = 50
      taints = [],
      subnet_selections = {
        public = false
        private = true
      }
    },
  ]
}
