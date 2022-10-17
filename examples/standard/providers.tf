variable "gitlab_token" {
  description = "Gitlab Token"
  default = ""
}

variable "aws_region" {
  description = "AWS Region for Provisioning"
  default     = "ap-southeast-1"
}

variable "aws_region_secondary" {
  description = "Secondary AWS Region for Provisioning"
  default     = "eu-west-1"
}

variable "tech_email" {
  description = "Tech Email for Contact"
  default = "tech@example.com"
}