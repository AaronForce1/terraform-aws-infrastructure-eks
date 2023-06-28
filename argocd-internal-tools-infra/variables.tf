## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  type        = string
  description = "AWS Region for all primary configurations"
}

variable "cluster_root_domain" {
  description = "Domain root where all kubernetes systems are orchestrating control"
  type = object({
    create             = optional(bool)
    name               = string
    ingress_records    = optional(list(string))
    additional_domains = optional(list(string)) ## TODO: Expand to include creation / NS allocation / etc.
  })
}

# TODO: Modularise better
variable "operator_domain_name" {
  description = "Domain root of operator cluster"
  type        = string
  default     = ""
}

variable "slave_domain_name" {
  description = "Domain root of slave cluster"
  type        = string
  default     = ""
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
    twingate      = bool
    teleport      = bool
  })
  default = {
    dashboard     = true
    gitlab_runner = false
    vault_consul  = true
    ingress       = true
    elasticstack  = false
    grafana       = true
    argocd        = false
    twingate      = false
    teleport      = false
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
      chart_version   = optional(string)
      kma_arn         = optional(string)
      value_file      = optional(string)
      extra_values    = optional(any)
      application_set = optional(list(string))
      application_sets = optional(list(object({
        filepath = string
        envvars  = map(string)
      })))
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
      additionalProjects = optional(list(object({
        name        = string
        description = string
        clusterResourceWhitelist = list(object({
          group = string
          kind  = string
        }))
        destinations = list(object({
          name      = string
          namespace = string
          server    = string
        }))
        sourceRepos = list(string)
      })))
    }))
    twingate = optional(object({
      chart_version  = optional(string)
      values_file    = optional(string)
      registryURL    = optional(string)
      url            = optional(string)
      network        = string
      logLevel       = optional(string)
      connectorCount = optional(number)
      management_group_configurations = list(object({
        name   = string
        create = bool
      }))
      resources = optional(list(object({
        name    = string
        address = string
        protocols = object({
          allow_icmp = bool
          tcp = object({
            policy = string
            ports  = list(string)
          })
          udp = object({
            policy = string
            ports  = list(string)
          })
        })
        group_configurations = list(object({
          name   = string
          create = bool
        }))
      })))
      resource_manifest = optional(object({
        address_list = list(object({
          name    = optional(string)
          address = string
        }))
        protocols = object({
          allow_icmp = bool
          tcp = object({
            policy = string
            ports  = list(string)
          })
          udp = object({
            policy = string
            ports  = list(string)
          })
        })
        group_configurations = list(object({
          name   = string
          create = bool
        }))
      }))
    }))
    teleport = optional(object({
      installations = optional(list(object({
        chart_name    = string
        chart_version = string
        values_file   = string
      })))
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
variable "eks_infrastructure_kms_arn" {
  default = ""
}
variable "hosted_zone_id" {
  default = ""
}
variable "kubernetes_cluster_id" {
  default = ""
}
