resource "helm_release" "gitlab-runner" {
  name             = "gitlab-runner-${var.app_namespace}-${var.tfenv}"
  depends_on       = [kubernetes_secret.AWS]
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.33.1"
  namespace        = "gitlab-runner"
  create_namespace = false

  values = [
    <<-EOF
      unregisterRunners: true
      imagePullPolicy: Always
      gitlabUrl: ${var.gitlab_url}
      runnerRegistrationToken = ${var.gitlab_runner_registration_token}
      concurrent: ${var.gitlab_runner_concurrent_agents}
      rbac:
        create: true
      runners:
        config: ${local.runner_config}
        tags: "kubernetes, cluster, ${var.sys_arch}"
        runUntagged: true
        secret: gitlab-registry-secret
        cache:
          secretName: s3access
    EOF
  ]
}

locals {
  runner_config = var.runner_config ? var.runner_config : <<EOF
    [[runners]]
      [runners.kubernetes]
        image = "docker:20.10-dind"
        image_pull_secrets = ["gitlab-registry-secret"]
        privileged = true
        namespace = "gitlab-runner"
        cpu_limit = "2"
        cpu_limit_overwrite_max_allowed = "4"
        cpu_request = "1"
        cpu_request_overwrite_max_allowed = "2"
        memory_limit = "2048Mi"
        memory_limit_overwrite_max_allowed = "4096Mi"
        memory_request = "500Mi"
        memory_request_overwrite_max_allowed = "1024Mi"
        service_cpu_limit = "0.5"
        service_cpu_request = "0.2"
        service_memory_limit = "1000Mi"
        service_memory_request = "500Mi"
        helper_cpu_limit = "0.2"
        helper_cpu_request = "0.1"
        helper_memory_limit = "256Mi"
        helper_memory_request = "128Mi"
        ephemeral_storage_limit = "2000Mi"
        ephemeral_storage_request = "100Mi"
        ephemeral_storage_limit_overwrite_max_allowed = "8000Mi"
        helper_ephemeral_storage_limit = "100Mi"
        helper_ephemeral_storage_limit_overwrite_max_allowed = "1000Mi"
        helper_ephemeral_storage_request = "1Mi"
        service_ephemeral_storage_limit = "100Mi"
        service_ephemeral_storage_limit_overwrite_max_allowed = "1000Mi"
        service_ephemeral_storage_request = "1Mi"
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
      [runners.cache]
        Type = "s3"
        Path = "gitlab_runner"
        Shared = false
        [runners.cache.s3]
          ServerAddress = "s3.amazonaws.com"
          BucketName = "gitlab-runner-cache-${var.tfenv}"
          BucketLocation = ${var.aws_region}
          Insecure = false
      EOF
}

variable "app_name" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "aws_region" {}
variable "gitlab_serviceaccount_id" {}
variable "gitlab_serviceaccount_secret" {}
variable "gitlab_runner_concurrent_agents" {}
variable "gitlab_runner_registration_token" {}
variable "sys_arch" {}
variable "runner_config" {
  default = ""
}