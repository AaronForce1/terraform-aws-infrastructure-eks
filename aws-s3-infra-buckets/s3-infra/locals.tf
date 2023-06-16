locals {
  role_policy_attachments = distinct(flatten([
    for s3 in var.eks_infrastructure_support_buckets : [
      for role_name in var.eks_managed_node_group_roles : {
        s3        = s3
        role_name = role_name.value
      }
    ]
    if s3.eks_node_group_access
  ]))
}
locals {
  additional_s3_infrastructure_buckets = try(coalesce(var.teleport_bucket, false), false) ? [
    {
      name                     = "teleport-cluster-session-recordings"
      bucket_acl               = "private"
      object_ownership         = "BucketOwnerPreferred"
      control_object_ownership = true
      eks_node_group_access    = false
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
