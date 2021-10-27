#Post Provisioning EFS Service Account annotation

Because the eks-efs-csi driver has a bug on its annotation and we cannot use kubernetes_service_account terraform resource to apply the annotation because the service account already exists and we cannot apply an update yet thru terraform. We need to manually apply the annotation to the service account that was created by the efs helm_release. To do that:

1. First make sure you are in the right context, if the cluster already exists `kubectl config get-clusters` then copy the cluster to `kubectl config use-context <cluster id>`. This will connect you to the cluster you want to apply. If you have not added the context yet, you can do `aws eks update-kubeconfig --name <name of the cluster> --profile <aws account profile> --region` to add the cluster on your kubeconfig.

2. Open the file `provisioning/kubernetes/aws-support/efs-service-account-values.yaml` edit the file and change the following values:

{account_id} matched with your AWS account ID
{var.app_name} matched with your app_name value set on terraform
{var.app_namespace} matched with the namespace used on the environment
{var.tfenv} matched with the tfenv

Save the file.

2. Apply the annotation from the values.yaml file by `kubectl apply -f provisioning/kubernetes/aws-support/efs-service-account-values.yaml`



