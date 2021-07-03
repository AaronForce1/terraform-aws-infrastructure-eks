module "s3_website_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.22"

  bucket = "gitlab-runner-${var.app_namespace}-${var.tfenv}-cache"

  acl           = "private"
  force_destroy = var.tfenv == "prod" ? true : false
  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }

  versioning = {
    enabled = true
  }

  cors_rule = []

  tags = {
    Name            = "gitlab-runner-${var.app_namespace}-${var.tfenv}-cache"
    Environment     = var.tfenv
    Namespace       = var.app_namespace
  }
}