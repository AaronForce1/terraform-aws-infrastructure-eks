resource "aws_security_group" "efs_security_group" {
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

  tags = var.tags
}
