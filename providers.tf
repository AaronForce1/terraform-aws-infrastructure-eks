provider "kubernetes" {
  host                   = data.aws_eks_cluster.my-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.my-auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.my-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.my-auth.token
  }
}