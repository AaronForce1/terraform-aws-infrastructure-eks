## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  description = "AWS Region for all primary configurations"
}

variable "aws_secondary_region" {
  description = "Secondary Region for certain redundant AWS components"
}

variable "aws_profile" {
  description = "AWS Profile"
  default     = ""
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

variable "eks_managed_node_groups" {
  description = "Override default 'single nodegroup, on a private subnet' with more advaned configuration archetypes"
  default     = []
  type        = any
  # type = list(object({
  #   name                   = string
  #   desired_capacity       = number
  #   max_capacity           = number
  #   min_capacity           = number
  #   instance_type          = string
  #   ami_type               = optional(string)
  #   key_name               = optional(string)
  #   public_ip              = optional(bool)
  #   create_launch_template = bool
  #   disk_size              = number
  #   disk_encrypted         = optional(bool)
  #   capacity_type          = optional(string)
  #   taints = optional(list(object({
  #     key            = string
  #     value          = string
  #     effect         = string
  #     affinity_label = bool
  #   })))
  #   subnet_selections = object({
  #     public  = bool
  #     private = bool
  #   })
  #   tags = optional(any)
  # }))
}

variable "cluster_root_domain" {
  description = "Domain root where all kubernetes systems are orchestrating control"
  type = object({
    create          = optional(bool)
    name            = string
    ingress_records = optional(list(string))
  })
}

# TODO: Modularise better
variable "operator_domain_name" {
  description = "Domain root of operator cluster"
  type        = string
  default     = ""
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

variable "cluster_name" {
  description = "Optional override for cluster name instead of standard {name}-{namespace}-{env}"
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes Cluster Version"
  default     = "1.21"
}

variable "instance_type" {
  # Standard Types (M | L | XL | XXL): m5.large | c5.xlarge | t3a.2xlarge | m5a.2xlarge
  description = "AWS Instance Type for provisioning"
  default     = "c5a.medium"
}

variable "instance_desired_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 2
}

variable "instance_min_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 1
}

variable "instance_max_size" {
  description = "Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2"
  default     = 4
}

variable "billingcustomer" {
  description = "Which Billingcustomer, aka Cost Center, is responsible for this infra provisioning"
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

variable "cluster_addons" {
  description = "An add-on is software that provides supporting operational capabilities to Kubernetes applications, but is not specific to the application: coredns, kube-proxy, vpc-cni"
  default = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
  }
  type = any
}

variable "vpc_flow_logs" {
  description = "Manually enable or disable VPC flow logs; Please note, for production, these are enabled by default otherwise they will be disabled; setting a value for this object will override all defaults regardless of environment"
  type = object({
    enabled = optional(bool)
  })
  default = {}
}


variable "elastic_ip_custom_configuration" {
  description = "By default, this module will provision new Elastic IPs for the VPC's NAT Gateways; however, one can also override and specify separate, pre-existing elastic IPs as needed in order to preserve IPs that are whitelisted; reminder that the list of EIPs should have the same count as nat gateways created."
  type = object({
    enabled             = bool
    reuse_nat_ips       = optional(bool)
    external_nat_ip_ids = optional(list(string))
  })
  default = {
    enabled             = false
    external_nat_ip_ids = []
    reuse_nat_ips       = false
  }
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

variable "aws_installations" {
  description = "AWS Support Components including Cluster Autoscaler, EBS/EFS Storage Classes, etc."
  type = object({
    storage_ebs = optional(object({
      eks_irsa_role = bool
      gp2           = bool
      gp3           = bool
      st1           = bool
    }))
    storage_efs = optional(object({
      eks_irsa_role       = bool
      eks_security_groups = bool
      efs                 = bool
    }))
    cluster_autoscaler   = optional(bool)
    route53_external_dns = optional(bool)
    kms_secrets_access   = optional(bool)
    cert_manager         = optional(bool)
  })
  default = {
    cluster_autoscaler   = true
    kms_secrets_access   = true
    route53_external_dns = true
    cert_manager         = true
    storage_ebs = {
      eks_irsa_role = true
      gp2           = true
      gp3           = true
      st1           = true
    }
    storage_efs = {
      efs                 = true
      eks_irsa_role       = true
      eks_security_groups = true
    }
  }
}

variable "helm_installations" {
  type = object({
    dashboard     = bool
    gitlab_runner = bool
    vault_consul  = bool
    ingress       = bool
    elasticstack  = bool
    grafana       = bool
    argocd        = bool
  })
  default = {
    dashboard     = true
    gitlab_runner = false
    vault_consul  = true
    ingress       = true
    elasticstack  = false
    grafana       = true
    argocd        = false
  }
}
variable "helm_configurations" {
  type = object({
    dashboard     = optional(string)
    gitlab_runner = optional(string)
    vault_consul = optional(object({
      consul_values           = optional(string)
      vault_values            = optional(string)
      enable_aws_vault_unseal = optional(bool)   # If Vault is enabled and deployed, by default, the unseal process is manual; Changing this to true allows for automatic unseal using AWS KMS"
      vault_nodeselector      = optional(string) # Allow for vault node selectors without extensive reconfiguration of the standard values file
      vault_tolerations       = optional(string) # Allow for tolerating certain taint on nodes, example usage, string:'NoExecute:we_love_hashicorp:true'
    }))
    ingress = optional(object({
      nginx_values       = optional(string)
      certmanager_values = optional(string)
    }))
    elasticstack = optional(string)
    grafana      = optional(string)
    argocd = optional(object({
      value_file      = optional(string)
      application_set = optional(list(string))
      repository_secrets = optional(list(object({
        name          = string
        url           = string
        type          = string
        username      = string
        password      = string
        secrets_store = string
      })))
      credential_templates = optional(list(object({
        name          = string
        url           = string
        username      = string
        password      = string
        secrets_store = string
      })))
      registry_secrets = optional(list(object({
        name          = string
        username      = string
        password      = string
        url           = string
        email         = string
        secrets_store = string
      })))
      generate_plugin_repository_secret = optional(bool)
    }))
  })
  default = {
    dashboard     = null
    gitlab_runner = null
    vault_consul  = null
    ingress       = null
    elasticstack  = null
    grafana       = null
    argocd        = null
  }
}

variable "custom_namespaces" {
  description = "Adding namespaces to a default cluster provisioning process"
  type        = list(string)
  default     = []
}

variable "custom_aws_s3_support_infra" {
  description = "Adding the ability to provision additional support infrastructure required for certain EKS Helm chart/App-of-App Components"
  type = list(object({
    name                                 = string
    bucket_acl                           = string
    aws_kms_key_id                       = optional(string)
    lifecycle_rules                      = any
    versioning                           = bool
    k8s_namespace_service_account_access = any
  }))
  default = []
}

variable "vpc_subnet_configuration" {
  type = object({
    base_cidr = string
    subnet_bit_interval = object({
      public  = number
      private = number
    })
    autogenerate = optional(bool)
  })
  description = "Configure VPC CIDR and relative subnet intervals for generating a VPC. If not specified, default values will be generated."
  default = {
    base_cidr = "172.%s.0.0/16"
    subnet_bit_interval = {
      public  = 2
      private = 6
    }
    autogenerate = true
  }
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

## TODO: Merge all the default node_group configurations together
variable "default_ami_type" {
  description = "Default AMI used for node provisioning"
  default     = "AL2_x86_64"
}

variable "default_capacity_type" {
  description = "Default capacity configuraiton used for node provisioning. Valid values: `ON_DEMAND, SPOT`"
  default     = "ON_DEMAND"
}

variable "registry_credentials" {
  description = "Create list of registry credential for different namespaces, username and password are fetched from AWS parameter store"
  type = list(object({
    name            = string
    namespace       = string
    docker_username = string
    docker_password = string
    docker_server   = string
    docker_email    = string
    secrets_store   = string
  }))
  default = []
}

