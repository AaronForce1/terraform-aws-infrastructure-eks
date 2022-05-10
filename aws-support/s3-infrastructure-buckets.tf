# module "aws_s3_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 3.1"

#   count = length(var.eks_infrastructure_support_buckets)

#   bucket = "${var.name_prefix}-${var.eks_infrastructure_support_buckets[count.index].name}"

#   acl           = var.eks_infrastructure_support_buckets[count.index].bucket_acl
#   force_destroy = var.tfenv == "prod" ? false : true

#   block_public_policy     = true
#   block_public_acls       = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         kms_master_key_id = var.eks_infrastructure_support_buckets[count.index].aws_kms_key
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#   versioning = {
#     status     = false
#   }
# }

# module "log_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 3.1"

#   bucket        = "${var.name_prefix}-logs-${var}"
#   acl           = "log-delivery-write"
#   force_destroy = true

#   attach_elb_log_delivery_policy        = true
#   attach_lb_log_delivery_policy         = true
#   attach_deny_insecure_transport_policy = true
#   attach_require_latest_tls_policy      = true
# }

# module "s3_elasticstack_bucket" {
  

#   logging = {
#     target_bucket = module.log_bucket.s3_bucket_id
#     target_prefix = "logs/"
#   }

#   lifecycle_rule = [
#     {
#       id      = "log"
#       enabled = true

#       tags = {
#         rule      = "log"
#         autoclean = "true"
#       }

#       transition = var.tfenv == "prod" ? [
#         {
#           days          = 30
#           storage_class = "STANDARD_IA"
#         },
#         {
#           days          = 60
#           storage_class = "GLACIER"
#         },
#         {
#           days          = 150
#           storage_class = "DEEP_ARCHIVE"
#         }
#         ] : [
#         {
#           days          = 30
#           storage_class = "ONEZONE_IA"
#         },
#       ]

#       expiration = {
#         days = var.tfenv == "prod" ? 365 : 60
#       }
#     }
#   ]

#   tags = {
#     Name            = "${var.app_name}-${var.app_namespace}-${var.tfenv}-logs"
#     Environment     = var.tfenv
#     Billingcustomer = var.billingcustomer
#     Description     = "Elasticstack Cluster-Application Logging"
#     Product         = "Elasticstack"
#     Namespace       = var.app_namespace
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "loki" {
#   bucket = aws_s3_bucket.loki.bucket

#   rule {
#     expiration {
#       days = var.loki_log_retention_days
#     }

#     filter {
#       prefix = "/"
#     }

#     id = "logs-retention"
#     status = "Enabled"
#   }

#   rule {
#     expiration {
#       days = var.loki_log_glacier_retention_days
#     }

#     transition {
#       days          = var.loki_log_glacier_days
#       storage_class = "GLACIER"
#     }

#     filter {
#       prefix = "/"
#     }

#     id = "logs-glacier"
#     status = var.loki_log_glacier_status
#   }
# }