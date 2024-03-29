resource "aws_security_group" "efs_security_group" {
  count = var.aws_installations.storage_efs.eks_security_groups ? 1 : 0

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}-efs"
  description = "${var.app_name}-${var.app_namespace}-${var.tfenv}-efs"
  vpc_id      = var.vpc_id
  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${var.base_cidr_block}"]
  }

  tags = {
    "Environment"     = var.tfenv
    "Terraform"       = "true"
    "Namespace"       = var.app_namespace
    "Billingcustomer" = var.billingcustomer
    "Product"         = var.app_name
    "Name"            = "${var.app_name}-${var.app_namespace}-${var.tfenv}-efs"
  }
}