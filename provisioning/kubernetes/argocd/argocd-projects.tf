resource "kubernetes_manifest" "argocd_project" {
  for_each = { for project in coalesce(var.additionalProjects, []) : project.name => project }
  depends_on = [
    helm_release.argocd
  ]

  manifest = {
    "apiVersion" : "argoproj.io/v1alpha1"
    "kind" : "AppProject"
    "metadata" : {
      "finalizers" : [
        "resources-finalizer.argocd.argoproj.io"
      ]
      "name" : each.value.name
      "namespace" : "argocd"
    }
    "spec" : {
      "description" : each.value.description
      "clusterResourceWhitelist" : each.value.clusterResourceWhitelist
      "destinations" : each.value.destinations
      "sourceRepos" : each.value.sourceRepos
    }
  }
  field_manager {
    name            = "spec"
    force_conflicts = true
  }
}

