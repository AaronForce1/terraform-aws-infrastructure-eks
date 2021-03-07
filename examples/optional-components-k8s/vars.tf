variable "gitlab_token" {
  description = "Gitlab Token"
}

variable "aws_region" {
  description = "AWS Region for Provisioning"
  default     = "ap-southeast-1"
}

variable "datadog_serviceacount_apikey" {
  description = "Datadog API Key for integration with Cluster"
  default     = ""
}