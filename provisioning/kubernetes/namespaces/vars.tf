variable "helm_installations" {
  type = object({
    gitlab_runner = bool
    vault_consul  = bool
    ingress       = bool
    elasticstack  = bool
    grafana       = bool
  })
}