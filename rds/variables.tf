variable "aws_region" {
  default = ""
}
variable "environment" {
  default = ""
}
variable "vpc_id" {
  default = ""
}
variable "db_major_engine_version" {
  default = ""
}
variable "db_parameter_group_family" {
  default = ""
}
variable "db_minor_engine_version" {
  default = ""
}
variable "db_engine" {
  default = ""
}
variable "multi_az" {
  default = false
  type    = bool
}

variable "apply_immediately" {
  default = false
  type    = bool
}

variable "deletion_protection" {
  default = false
  type    = bool
}

variable "final_snapshot_identifier" {
  default = "final_snapshot"
}
variable "backup_window" {
  default = "03:00-06:00"
}
variable "backup_retention_period" {
  default = "7"
}
variable "db_instance_name" {
  default = ""
}
variable "db_name" {
  default = ""
}
variable "db_instance_type" {
  default = ""
}
variable "maintenance_window" {
  default = "Wed:22:30-Wed:23:00"
}

variable "db_subnet_group_name" {
  default = "main-db"
}

variable "allocated_storage" {
  default = "100"
}
variable "max_allocated_storage" {
  default = "0"
}

variable "create_db_option_group" {
  default = false
  type    = bool
}
variable "create_db_parameter_group" {
  default = true
  type    = bool
}
variable "create_db_subnet_group" {
  default = false
  type    = bool
}
variable "storage_encrypted" {
  default = true
  type    = bool
}
variable "subnet_ids" {
  default = []
}
variable "publicly_accessible" {
  default = false
  type    = bool
}
variable "allow_major_version_upgrade" {
  default = false
  type    = bool
}
variable "auto_minor_version_upgrade" {
  default = false
  type    = bool
}

variable "performance_insights_retention_period" {
  default = 7
}
variable "performance_insights_enabled" {
  default = true
}

variable "db_port" {
  default = "5432"
}

variable "primary_db_parameters" {
  default = []
  type    = list(map(string))
}


variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}

variable "create_monitoring_role" {
  type    = bool
  default = true
}

variable "monitoring_interval" {
  type    = number
  default = 0
}

variable "monitoring_role_arn" {
  type    = string
  default = null
}

variable "monitoring_role_name" {
  type    = string
  default = "rds-monitoring-role"
}

variable "retention_period" {
  type    = number
  default = 7
}

variable "master_username" {
  default = "root"
}
