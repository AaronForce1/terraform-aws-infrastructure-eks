resource "kubernetes_storage_class" "gp2-storage-class" {
  count = try(var.aws_installations.storage_ebs.gp2, false) ? 1 : 0
  metadata {
    name = "gp2-retain"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
}
