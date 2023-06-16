module "aws-support" {
  source = "./s3-infra"

  oidc_url                           = var.oidc_url
  app_name                           = var.app_name
  app_namespace                      = var.app_namespace
  tfenv                              = var.tfenv
  name_prefix                        = var.name_prefix
  eks_infrastructure_support_buckets = var.eks_infrastructure_support_buckets
  eks_infrastructure_kms_arn         = var.eks_infrastructure_kms_arn
  eks_managed_node_group_roles       = var.eks_managed_node_group_roles
  tags                               = var.base_tags
  thanos_slave_role                  = var.thanos_slave_role
  slave_assume_operator_roles        = var.slave_assume_operator_roles
  eks_slave                          = var.eks_slave
  teleport_bucket                    = var.teleport_bucket
  providers = {
    aws.destination-aws-provider     = aws.destination-aws-provider
    aws                              = aws
  }
}
