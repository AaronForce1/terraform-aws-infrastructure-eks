provider "aws" {
  region  = var.aws_region
}

provider "aws" {
  alias   = "secondary"
  region  = var.aws_region_secondary
}

provider "kubernetes" {
  host                   = module.infrastructure-terraform-eks.kubernetes-cluster-endpoint
  token                  = module.infrastructure-terraform-eks.kubernetes-cluster-auth.token
  cluster_ca_certificate = base64decode(module.infrastructure-terraform-eks.kubernetes-cluster-certificate-authority-data)
}

provider "helm" {
  kubernetes {
    host                   = module.infrastructure-terraform-eks.kubernetes-cluster-endpoint
    token                  = module.infrastructure-terraform-eks.kubernetes-cluster-auth.token
    cluster_ca_certificate = base64decode(module.infrastructure-terraform-eks.kubernetes-cluster-certificate-authority-data)
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = module.infrastructure-terraform-eks.kubernetes-cluster-endpoint
  token                  = module.infrastructure-terraform-eks.kubernetes-cluster-auth.token
  cluster_ca_certificate = base64decode(module.infrastructure-terraform-eks.kubernetes-cluster-certificate-authority-data)
}