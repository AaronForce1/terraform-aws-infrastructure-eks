resource "kubernetes_manifest" "argocd_project" {
  for_each = { for project in coalesce(var.additionalProjects, []) : project.name => project }

  manifest = yamldecode(<<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  name: ${each.value.name}
  namespace: argocd
spec:
  description: ${each.value.description}
  clusterResourceWhitelist: ${jsonencode(each.value.clusterResourceWhitelist)}
  destinations: ${jsonencode(each.value.destinations)}
  sourceRepos: ${jsonencode(each.value.sourceRepos)}
YAML
  )
  field_manager {
    name            = "spec"
    force_conflicts = true
  }
}

