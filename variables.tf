## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  description = "Region for the VPC"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
  # default = [
  #   "777777777777",
  #   "888888888888",
  # ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
  # default = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
  # default = [
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]
}

variable "managed_node_groups" {
  description = "Override default 'single nodegroup, on a private subnet' with more advaned configuration archetypes"
  type = list(object({
    name = string
    desired_capacity = number
    max_capacity = number
    min_capacity = number
    instance_type = string
    key_name = string
    public_ip = bool
    create_launch_template = bool
    disk_size = number
    taints = list(object({
      key = string
      value = string
      effect = string
    }))
    subnet_selections = object({
      public = bool
      private = bool
    })
  }))
}

variable "root_domain_name" {
  description = "Domain root where all kubernetes systems are orchestrating control"
}

variable "app_name" {
  description = "Application Name"
  default     = "eks"
}

variable "app_namespace" {
  description = "Tagged App Namespace"
}

variable "tfenv" {
  description = "Environment"
}

variable "cluster_version" {
  description = "Kubernetes Cluster Version"
  default     = "1.18"
}

variable "instance_type" {
  # Standard Types (M | L | XL | XXL): m5.large | c5.xlarge | t3a.2xlarge | m5a.2xlarge
  description = "AWS Instance Type for provisioning"
  default     = "c5a.large"
}

variable "instance_desired_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 8
}

variable "instance_min_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 2
}

variable "instance_max_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 12
}

variable "billingcustomer" {
  description = "Which BILLINGCUSTOMER is setup in AWS"
}

variable "root_vol_size" {
  description = "Root Volume Size"
  default     = "50"
}

variable "node_key_name" {
  description = "EKS Node Key Name"
  default = ""
}

variable "node_public_ip" { 
  description = "assign public ip on the nodes"
  default = false
}

variable "helm_installations" {
  type = object({
    gitlab_runner = bool
    vault_consul  = bool
    ingress       = bool
    elasticstack  = bool
    grafana       = bool
  })
  default = {
    gitlab_runner = false
    vault_consul  = true
    ingress       = true
    elasticstack  = false
    grafana       = true
  }
}

variable "enable_aws_vault_unseal" {
  description = "If Vault is enabled and deployed, by default, the unseal process is manual; Changing this to true allows for automatic unseal using AWS KMS"
  default     = false
}

variable "google_clientID" {
  description = "Used for Infrastructure OAuth: Google Auth Client ID"
}

variable "google_clientSecret" {
  description = "Used for Infrastructure OAuth: Google Auth Client Secret"
}

variable "google_authDomain" {
  description = "Used for Infrastructure OAuth: Google Auth Domain"
}

variable "create_launch_template" { 
  description = "enable launch template on node group"
  default = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "If the cluster endpoint is to be exposed to the public internet, specify CIDRs here that it should be restricted to"
  type = list(string)
  default = []
}

variable "default_ami_type" {
  description = "Default AMI used for node provisioning"
  default = "AL2_x86_64"
}
