variable "gitlab_token" {
  description = "Gitlab Token"
}

variable "aws_region" {
  description = "AWS Region for Provisioning"
  default     = "ap-southeast-1"
}

variable "aws_region_secondary" {
  description = "Secondary AWS Region for Provisioning"
  default     = "ap-east-1"
}