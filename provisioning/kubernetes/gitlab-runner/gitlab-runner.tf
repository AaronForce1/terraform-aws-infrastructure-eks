resource "helm_release" "gitlab-runner" {
  name             = "gitlab-runner-${var.app_namespace}-${var.tfenv}"
  depends_on       = [kubernetes_secret.AWS]
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.26.0"
  namespace        = "gitlab-runner"
  create_namespace = false

  values = [
    # file("${path.module}/values.v0.20.0.yaml")
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v0.23.0.yaml"
}

locals {
  helmChartValues = {
    "unregisterRunners"       = true,
    "imagePullPolicy"         = "Always",
    "gitlabUrl"               = "https://git.hk.asiaticketing.com",
    "runnerRegistrationToken" = var.gitlab_runner_registration_token,
    "concurrent"              = var.gitlab_runner_concurrent_agents,
    "rbac" = {
      "create" : true
    },
    "runners" = {
      "config" : <<EOF
        [[runners]]
          [runners.kubernetes]
            image = "docker:20.10.2-dind"
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
            helper_image =  "registry.git.hk.asiaticketing.com/ticketflap/ticketing-v2/gitlab-runner-helper:$CI_RUNNER_VERSION"
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
              BucketName = "infra-git-prod-gitlab-runner-cache"
              BucketLocation = "ap-southeast-1"
              Insecure = false
        EOF
      "tags" : "kubernetes, cluster",
      "runUntagged" : true,
      "secret" : "gitlab-registry-secret"
      "cache" : {
        "secretName" : "s3access"
      }
    }
  }
}

variable "app_name" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "aws_region" {}
variable "gitlab_serviceaccount_id" {}
variable "gitlab_serviceaccount_secret" {}
variable "gitlab_runner_concurrent_agents" {}
variable "gitlab_runner_registration_token" {}