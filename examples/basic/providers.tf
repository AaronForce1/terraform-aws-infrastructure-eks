provider "aws" {
  region  = var.aws_region
}

provider "aws" {
  alias   = "secondary"
  region  = var.aws_region_secondary
}

provider "kubernetes" {
  # config_path = "~/.kube/config"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes {
    # config_path = "~/.kube/config"
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}