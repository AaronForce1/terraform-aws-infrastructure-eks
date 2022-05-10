resource "kubernetes_storage_class" "gp2-storage-class" {
  count = var.aws_installations.storage_ebs.gb2 ? 1 : 0
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
