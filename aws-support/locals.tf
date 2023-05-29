locals {
  additional_s3_infrastructure_buckets = try(coalesce(var.aws_installations.teleport.cluster, false), false) ? [
    {
      name                  = "teleport-cluster-session-recordings"
      bucket_acl            = "private"
      eks_node_group_access = false
      lifecycle_rules = [
        {
          id      = "retention"
          enabled = true
          filter = {
            prefix = "/"
          }
          transition = []
          expiration = {
            days = 120
          }
        },
        {
          id      = "glacier"
          enabled = false
          filter = {
            prefix = "/"
          }
          transition = [{
            days          = 90
            storage_class = "GLACIER"
          }]
          expiration = {
            days = 365
          }
        }
      ]
      versioning = true
      # Managed by TELEPORT-AWS-IAM
      k8s_namespace_service_account_access = []
      aws_kms_key_id                       = var.eks_infrastructure_kms_arn
    }
  ] : []
}