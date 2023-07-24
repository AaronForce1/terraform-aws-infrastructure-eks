locals {
  name = var.db_instance_name
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-rds-sg"
  description = "PostgreSQL security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.selected.cidr_block
    }
  ]
}


module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1"

  identifier                            = var.db_instance_name
  instance_class                        = var.db_instance_type
  engine                                = var.db_engine
  major_engine_version                  = var.db_major_engine_version
  engine_version                        = "${var.db_major_engine_version}.${var.db_minor_engine_version}"
  family                                = var.db_parameter_group_family
  allocated_storage                     = var.allocated_storage
  max_allocated_storage                 = var.max_allocated_storage
  port                                  = var.db_port
  db_name                               = var.db_name
  username                              = var.master_username
  vpc_security_group_ids                = [module.security_group.security_group_id]
  multi_az                              = var.multi_az
  maintenance_window                    = var.maintenance_window
  deletion_protection                   = var.deletion_protection
  backup_window                         = var.backup_window
  backup_retention_period               = var.backup_retention_period #
  create_db_parameter_group             = false
  parameter_group_name                  = module.rds_db_parameter_group_db.db_parameter_group_id
  create_db_option_group                = var.create_db_option_group
  create_db_subnet_group                = var.create_db_subnet_group
  subnet_ids                            = var.create_db_subnet_group == true ? var.subnet_ids : []
  db_subnet_group_name                  = var.db_subnet_group_name
  storage_encrypted                     = var.storage_encrypted
  publicly_accessible                   = var.publicly_accessible
  apply_immediately                     = var.apply_immediately
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  create_monitoring_role = var.create_monitoring_role
  monitoring_interval    = var.monitoring_interval
  monitoring_role_arn    = var.monitoring_role_arn

  tags = {
    Name        = var.db_instance_name
    Environment = var.environment
  }
}

module "rds_db_parameter_group_db" {
  create  = var.create_db_parameter_group
  source  = "terraform-aws-modules/rds/aws//modules/db_parameter_group"
  version = "6.1"

  name            = "${var.db_instance_name}-parameter"
  use_name_prefix = true
  parameters      = var.primary_db_parameters
  family          = var.db_parameter_group_family
}
