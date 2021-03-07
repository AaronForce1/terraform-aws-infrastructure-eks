variable "aws_region" {
  description = "AWS Region for Provisioning"
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "Profile of AWS Credential to fetch from ~/.aws/credentials file"
}

variable "serviceaccount_role" {
  description = "Service Account Role expected to run the necessary infrastructure provisioning"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "root_domain_name" {
  description = "Domain root where all kubernetes systems are orchestrating control"
}

variable "app_namespace" {
  description = "Tagged App Namespace"
}

variable "tfenv" {
  description = "Environment"
}

variable "app_name" {
  description = "Application Name"
  default     = "eks"
}


## GITLAB KUBERNETES CLUSTER MANAGEMENT

variable "gitlab_token" {
  description = "Gitlab Token"
}

variable "gitlab_namespace" {
  description = "Gitlab Namespace where K8s can be viewed and monitored at"
  default     = "technology/system/infra"
}

variable "cluster_environment_scope" {
  description = "Environment Scope that the cluster should cover according to Gitlab CI"
  default     = "*"
}

## GITLAB RUNNER KUBERNETES INTEGRATION

variable "CI_RUNNER_REVISION" {
  description = "Gitlab Runner Revision for helper image"
  default     = "x86_86ad88ea"
}

variable "gitlab_runner_concurrent_agents" {
  description = "Gitlab Runner Concurrent Agent Configurations"
  default     = 10
}
variable "gitlab_runner_registration_token" {
  description = "Gitlab Runner Registration Token"
  default     = ""
}

# Gitlab Runner Cache S3 Storage Management

variable "gitlab_serviceaccount_id" {
  description = "AWS ACCESS KEY ID for storing gitlab runner cache/reports in S3"
  default     = ""
}


variable "gitlab_serviceaccount_secret" {
  description = "AWS ACCESS KEY SECRET for storing gitlab runner cache/reports in S3"
  default     = ""
}