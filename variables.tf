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
    name                   = string
    desired_capacity       = number
    max_capacity           = number
    min_capacity           = number
    instance_type          = string
    ami_type               = optional(string)
    key_name               = string
    public_ip              = bool
    create_launch_template = bool
    disk_size              = number
    taints = list(object({
      key            = string
      value          = string
      effect         = string
      affinity_label = bool
    }))
    subnet_selections = object({
      public  = bool
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
  default     = "1.21"
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
  default     = ""
}

variable "node_public_ip" {
  description = "assign public ip on the nodes"
  default     = false
}

variable "vpc_flow_logs" {
  description = "Manually enable or disable VPC flow logs; Please note, for production, these are enabled by default otherwise they will be disabled; setting a value for this object will override all defaults regardless of environment"
  ## TODO: BUG - Seems that defining optional variables messes up the "try" terraform function logic so it needs to be removed altogether to function correctly
  # type = object({
  #   enabled = optional(bool)
  # })
  default = {}
}

variable "nat_gateway_custom_configuration" {
  description = "Override the default NAT Gateway configuration, which configures a single NAT gateway for non-prod, while one per AZ on tfenv=prod"
  type = object({
    enabled                           = bool
    enable_nat_gateway                = bool
    enable_dns_hostnames              = bool
    single_nat_gateway                = bool
    one_nat_gateway_per_az            = bool
    enable_vpn_gateway                = bool
    propagate_public_route_tables_vgw = bool
  })
  default = {
    enable_dns_hostnames              = true
    enable_nat_gateway                = true
    enable_vpn_gateway                = false
    enabled                           = false
    one_nat_gateway_per_az            = true
    propagate_public_route_tables_vgw = false
    single_nat_gateway                = false
  }
}

variable "helm_installations" {
  type = object({
    gitlab_runner     = bool
    gitlab_k8s_agent  = bool
    vault_consul      = bool
    ingress           = bool
    elasticstack      = bool
    grafana           = bool
    stakater_reloader = bool
    metrics_server    = bool
  })
  default = {
    gitlab_runner     = false
    gitlab_k8s_agent  = false
    vault_consul      = true
    ingress           = true
    elasticstack      = false
    grafana           = true
    stakater_reloader = true
    metrics_server    = true
  }
}

variable "vpc_subnet_configuration" {
  type = object({
    base_cidr           = string
    subnet_bit_interval = number
    autogenerate        = optional(bool)
  })
  description = "Configure VPC CIDR and relative subnet intervals for generating a VPC. If not specified, default values will be generated."
  default = {
    base_cidr           = "172.%s.0.0/16"
    subnet_bit_interval = 4
    autogenerate        = true
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
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "If the cluster endpoint is to be exposed to the public internet, specify CIDRs here that it should be restricted to"
  type        = list(string)
  default     = []
}

variable "vault_nodeselector" {
  description = "for placing node/consul on specific nodes, example usage, string:'eks.amazonaws.com/nodegroup: vaultconsul_group'"
  default     = ""
}

variable "vault_tolerations" {
  description = "for tolerating certain taint on nodes, example usage, string:'NoExecute:we_love_hashicorp:true'"
  default     = ""
}

variable "default_ami_type" {
  description = "Default AMI used for node provisioning"
  default     = "AL2_x86_64"
}

variable "gitlab_kubernetes_agent_config" {
  description = "Configuration for Gitlab Kubernetes Agent"
  type = object({
    gitlab_agent_url    = string
    gitlab_agent_secret = string
  })
  sensitive = true
  default = {
    gitlab_agent_url    = ""
    gitlab_agent_secret = ""
  }
}

variable "letsencrypt_email" {
  description = "email used for the clusterissuer email definition (spec.acme.email)"
}

### AWS Cluster Autoscaling 
variable "aws_autoscaler_scale_down_util_threshold" {
  description = "AWS Autoscaling, scale_down_util_threshold (AWS defaults to 0.5, but raising that to 0.7 to be a tad more aggressive with scaling back)"
  default     = 0.7
}

variable "aws_autoscaler_skip_nodes_with_local_storage" {
  description = "AWS Autoscaling, skip_nodes_with_local_storage (AWS defaults to true, also modifying to false for more scaling back)"
  default     = "false"
}

variable "aws_autoscaler_skip_nodes_with_system_pods" {
  description = "AWS Autoscaling, skip_nodes_with_system_pods (AWS defaults to true, but here default to false, again to be a little bit more aggressive with scaling back)"
  default     = "false"
}

variable "aws_autoscaler_cordon_node_before_term" {
  description = "AWS Autoscaling, cordon_node_before_term (AWS defaults to false, but setting it to true migth give a more friendly removal process)"
  default     = "true"
}

variable "extra_tags" {
  type    = map(any)
  default = {}
}

variable "ipv6" {
  type = object({
    enable                                         = bool
    assign_ipv6_address_on_creation                = bool
    private_subnet_assign_ipv6_address_on_creation = bool
    public_subnet_assign_ipv6_address_on_creation  = bool
  })
  default = {
    enable                                         = false
    assign_ipv6_address_on_creation                = true
    private_subnet_assign_ipv6_address_on_creation = true
    public_subnet_assign_ipv6_address_on_creation  = true
  }
}
