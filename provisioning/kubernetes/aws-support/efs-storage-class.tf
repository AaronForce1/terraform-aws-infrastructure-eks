resource "kubernetes_storage_class" "efs-storage-class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
}