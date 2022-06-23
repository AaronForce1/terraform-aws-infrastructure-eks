data "aws_ssm_parameter" "argocd_kubernetes_infrastructure_username" {
  name = "/repository/argocd-kubernetes-infrastructure/username"
}

data "aws_ssm_parameter" "argocd_kubernetes_infrastructure_password" {
  name = "/repository/argocd-kubernetes-infrastructure/password"
}

data "aws_ssm_parameter" "argocd_application_ssh" {
  name = "/repository/kubernetes-application/ssh"
}

data "aws_ssm_parameter" "argocd_generic_helm_chart_registry_username" {
  name = "/repository/generic-helm-chart/username"
}

data "aws_ssm_parameter" "argocd_generic_helm_chart_registry_password" {
  name = "/repository/generic-helm-chart/password"
}

resource "kubernetes_secret" "argocd_application_credential_template" {
  metadata {
    name      = "repository-application-template"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    url = "git@gitlab.int.hextech.io:metazen/kubernetes-application.git"
    type = "git"
    sshPrivateKey = data.aws_ssm_parameter.argocd_application_ssh.value
  }
}

resource "kubernetes_secret" "argocd_helm_chart_registry" {
  metadata {
    name      = "repository-generic-helm-chart"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name     = "generic-helm-chart"
    url      = "https://gitlab.int.hextech.io/api/v4/projects/645/packages/helm/stable"
    type     = "helm"
    username = data.aws_ssm_parameter.argocd_generic_helm_chart_registry_username.value
    password = data.aws_ssm_parameter.argocd_generic_helm_chart_registry_password.value
  }
}

resource "kubernetes_secret" "argocd_infrastructure_repository" {
  metadata {
    name      = "repository-infrastructure-repository"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url = "https://gitlab.int.hextech.io/technology/infra/argocd-kubernetes-infrastructure.git"
    type = "git"
    username = data.aws_ssm_parameter.argocd_kubernetes_infrastructure_username.value
    password = data.aws_ssm_parameter.argocd_kubernetes_infrastructure_password.value
  }
}

# resource "kubernetes_secret" "argocd_metazen_develop_cluster" {
#   metadata {
#     name      = "cluster-metazen-develop"
#     namespace = "argocd"
#     labels = {
#       "argocd.argoproj.io/secret-type" = "cluster"
#     }
#   }

#   data = {
#     name   = "metazen-develop"
#     server = "https://1035EFCAD5881E5FBE614EFEF1C7DFF4.sk1.ap-southeast-1.eks.amazonaws.com"
#     config = jsonencode({
#       bearerToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IlRpRzZ1OUZCemR5aW1WY0hsa1BmNEoweEtJUE9rRDRsUWxtZ1NBTmVyWkkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtYWRtaW4tdG9rZW4tY3d3bXciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGFzaGJvYXJkLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYWQzNzY2ZmItYjQ4Yy00NzNhLTlkYzgtMDUwNTM4OTM4Zjk3Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmRhc2hib2FyZC1hZG1pbiJ9.WnqgveQAZ8iw6Ye35HDo_EowyScRd9KjVYMqTc_AURNdNTP5IUtUuU-J-3xRrvYnQ5ekSqzr-PvitgErfytet6RLNmqPh9eN7XkZJdQ4cZXgh_JQzUNjK7dmrQz_9PQzkHjh1hZxgCThFISrW9u4axN6lP4JmI2j0S6u1JzPQgQQ2eQov5XUbXbhgDvWgHa-wt94S7LA9yzi_QoJdIMn5HFOpOpZobMlTOAvO-XTEeOv1AyB0xZ0KbCfyC1Do6VLtL7Fd7JNB2Nmrgb4LcSnqbwDjyQCmiU-I5J4tXr-5QdlzhT3rw4fkJ6oKFHovICFNWRS__GBmwgVvEAouPEfXA"
#       tlsClientConfig = {
#         insecure = false,
#         caData = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EVXhNREE1TWpJeE1Wb1hEVE15TURVd056QTVNakl4TVZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHRtCmJHM2h1bzNuMCtuTEMvMDN6SEI0R3p2T1RQanJBbk4zcXhhMDVJTGpEVFczUHFZZzdtOWF4RkxlbklGTUFuZDkKd0hRVDVib0laS1BXZ0RHaERIOTdIOGlwWUlhQnl1TkkweUFhQnBOVjdBd0llekFyeitmQ0syQXFMWUkyNEdlNgovWHNrWTVFOXpVNms2dUFnK0x5RERnempFVEhNbnZHbmcwbVdNd3BkN1pFa2o0K2licUo0ZTNzQnF6UmZ5bEwyCkl3Rk1ZUWZ2bjZQOXJFUVovSzZMMXdoc3JuRmM2QTVzMWhXRlp4cHN5bmpXeHlxVXZUZ0pSRUtsWUJXVjFVTFAKa3B3NFk1MkMzY2ROSndLazlhK2l0dWJOdDRBWWkreDVIdmZFemhSeFhmajZNdXhUU2NTT0VoZGFPT2NnbGNueQpidlVZVEdURUxmZ1NtL3ZnTkVNQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZCWlB5T1N1bUswaG5hUTBPUjJvMDRsaTdvTGFNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBV0lBVVFOek4wS1plckdiVkFhS28rSGxmd3gzeTI1TTdheU5lc3lCeHl6TFhnVEhRUwp4UkhUNEdDb3pmLzJSei9leFNVR2V1ZlZzV3hEZ3VVQVM2ckVjV1I5TWRYUVJQVDJmbDJFOTA5TzJmS1pYZmR3CmdIOXpoY1JWRXlYNVJVZzVvSnBWVCtIL3daZVlydm1iYWFGT2M5WVpPMWduZXRXL1VkQjhOWk5nVGRTcjlSSjEKa1Q5akE0VVd2ZGtDZjhPbnVEUndic0VraE9oVjhiVjAxMTFHUGhVTUk4cjNURlZoRE1SVFlyWDJyb2o0TFY0NgpWVWxMSGVROWlQK3QrdlZ0YkYxWkxJekpoR2wydVJzKzZMMjR0UllYVWFnZmk5UzBPejFBYlFHS092R1ZLVk5pCldjT0cvcVFZUW9iN3N2cUViYUxJUGJNZXkxTjNoRnp0OWY5dwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
#       }
#     })
#   }
# }