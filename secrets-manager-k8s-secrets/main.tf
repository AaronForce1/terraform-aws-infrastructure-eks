data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

module "secrets_manager" {
  source = "./secrets-manager"
  secrets = var.secrets
  secretsmanager_name = var.secretsmanager_secrets_name
  kms_key_arn         = var.kms_key_arn
}

module "kubernetes_secrets" {
  depends_on = [module.secrets_manager]
  source     = "./k8s-secrets"

  secrets_manager_secret_arn        = module.secrets_manager.secret_arn
  secrets_manager_secret_version_id = module.secrets_manager.latest_version_id
  eks_cluster_name                  = var.eks_cluster_name
  secrets                           = var.secrets
}


output "secrets_manager_secret_arn" {
  value = module.secrets_manager.secret_arn
}

output "secrets_manager_latest_version_id" {
  value = module.secrets_manager.latest_version_id
}
