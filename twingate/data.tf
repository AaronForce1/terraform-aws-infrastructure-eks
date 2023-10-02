data "aws_eks_cluster" "cluster" {
  name = var.kubernetes_cluster_id
}

# tflint-ignore: terraform_unused_declarations
data "aws_eks_cluster_auth" "cluster" {
  name = var.kubernetes_cluster_id
}
