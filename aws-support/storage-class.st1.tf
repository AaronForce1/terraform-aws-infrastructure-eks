#resource "kubernetes_storage_class" "st1-storage-class" {
#  count = try(var.aws_installations.storage_ebs.st1, false) ? 1 : 0
#  metadata {
#    name = "st1"
#  }
#  storage_provisioner = "kubernetes.io/aws-ebs"
#  reclaim_policy      = "Retain"
#  parameters = {
#    type = "st1"
#  }
#}
