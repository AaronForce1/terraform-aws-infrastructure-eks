resource "helm_release" "gitlab-runner" {
  name             = "gitlab-runner-${var.app_namespace}-${var.tfenv}"
  depends_on       = [kubernetes_secret.AWS]
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.23.0"
  namespace        = "gitlab-runner"
  create_namespace = false

  values = [
    local_file.values_yaml.content
  ]
}

resource "local_file" "values_yaml" {
  content  = yamlencode(local.helmChartValues)
  filename = "${path.module}/src/values.overrides.v0.23.0.yaml"
}

## TODO: Configure more flexible gitlab runner configurations (runner cache in s3 versus locally, etc)

locals {
  helmChartValues = {
    "unregisterRunners"       = true,
    "imagePullPolicy"         = "Always",
    "gitlabUrl"               = "https://gitlab.com",
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
            cpu_limit = "4"
            cpu_limit_overwrite_max_allowed = "6"
            cpu_request = "2"
            cpu_request_overwrite_max_allowed = "6"
            memory_limit = "4096Mi"
            memory_limit_overwrite_max_allowed = "8192Mi"
            memory_request = "1024Mi"
            memory_request_overwrite_max_allowed = "2048Mi"
            service_cpu_limit = "2"
            service_cpu_request = "0.5"
            service_memory_limit = "2048Mi"
            service_memory_request = "500Mi"
            helper_cpu_limit = "2"
            helper_cpu_request = "0.5"
            helper_memory_limit = "2048Mi"
            helper_memory_request = "500Mi"
            helper_image =  "registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${var.CI_RUNNER_REVISION}"
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
        "secretName" : "gitlab-runner-eks"
      }
    }
  }
}

variable "app_name" {}
variable "app_namespace" {}
variable "tfenv" {}
variable "aws_region" {}
variable "CI_RUNNER_REVISION" {}
variable "gitlab_serviceaccount_id" {}
variable "gitlab_serviceaccount_secret" {}
variable "gitlab_runner_concurrent_agents" {}
variable "gitlab_runner_registration_token" {}