# infrastructure-terraform-eks

[![LICENSE](https://img.shields.io/badge/license-Apache_2-blue)](https://opensource.org/licenses/Apache-2.0)

A custom-build terraform module, leveraging terraform-aws-eks to create a managed Kubernetes cluster on AWS EKS. In addition to provisioning simply an EKS cluster, this module alongside additional components to complete an entire end-to-end base stack for a functional kubernetes cluster for development and production level environments, including a base set of software that can/should be commonly used across all clusters. Primary integrated sub-modules include:
- [AWS EKS Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [AWS VPC Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)

## Assumptions

* You want to create an EKS cluster and an autoscaling group of workers for the cluster.
* You want these resources to exist within security groups that allow communication and coordination.
* You want to generate an accompanying Virtual Private Cloud (VPC) and subnets where the EKS resources will reside. The VPC satisfies [EKS requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).
* You want specific security provisions in place, including the use of private subnets for all nodes.
* The base ingress controller to be used is Nginx-Ingress Controller with internet-facing AWS network load balancers instead of being controlled by more reactive AWS Application Load Balancers.


## Important note

The `cluster_version` is the required variable. Kubernetes is evolving a lot, and each major version includes new features, fixes, or changes.

**Always check [Kubernetes Release Notes](https://kubernetes.io/docs/setup/release/notes/) before updating the major version.**

You also need to ensure your applications and add ons are updated, or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

An example of harming update was the removal of several commonly used, but deprecated  APIs, in Kubernetes 1.16. More information on the API removals, see the [Kubernetes blog post](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/).

For windows users, please read the following [doc](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#deploying-from-windows-binsh-file-does-not-exist).

## Usage

### Provisioning Sequence

1. Once AWS Credentials (see notes below) are set up on your local machine, it is recommended to follow docker-compose command in order to initialise terraform state within the context of Gitlab. However, you can also manage terraform state in other ways. An example of initialising terraform with a gitlab-managed state is shown here:
```
export TF_ADDRESS=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_VAR_app_name}-${TF_VAR_app_namespace}-${TF_VAR_tfenv} && \ 
terraform init \
  -backend-config="address=${TF_ADDRESS}" \
  -backend-config="lock_address=${TF_ADDRESS}/lock" \
  -backend-config="unlock_address=${TF_ADDRESS}/lock" \
  -backend-config="username=${TF_VAR_gitlab_username}" \
  -backend-config="password=${TF_VAR_gitlab_token}" \
  -backend-config="lock_method=POST" \
  -backend-config="unlock_method=DELETE" \
  -backend-config="retry_wait_min=5"
```
2. `terraform plan`
3. `terraform apply`
4. `terraform destroy`


## Other documentation

* [Autoscaling](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md): How to enable worker node autoscaling.
* [Enable Docker Bridge Network](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/enable-docker-bridge-network.md): How to enable the docker bridge network when using the EKS-optimized AMI, which disables it by default.
* [Spot instances](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md): How to use spot instances with this module.
* [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md): Minimum IAM permissions needed to setup EKS Cluster.
* [FAQ](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md): Frequently Asked Questions

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

## Contributing

Report issues/questions/feature requests on in the [issues](https://gitlab.com/magnetic-asia/infrastructure-as-code/infrastructure-terraform-eks/issues/new) section.

Full contributing [guidelines are covered here](https://gitlab.com/magnetic-asia/infrastructure-as-code/infrastructure-terraform-eks/blob/master/.github/CONTRIBUTING.md).

## Change log

- The [changelog](https://gitlab.com/magnetic-asia/infrastructure-as-code/infrastructure-terraform-eks/tree/master/CHANGELOG.md) captures all important release notes from 1.1.17

## Authors

Created by [Aaron Baideme](https://gitlab.com/aaronforce1) - aaron.baideme@magneticasia.com

Supported by Ronel Cartas - ronel.cartas@magneticasia.com

## License

MIT Licensed. See [LICENSE](https://gitlab.com/magnetic-asia/infrastructure-as-code/infrastructure-terraform-eks/tree/master/LICENSE) for full details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.10 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | ~> 3.4 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.10 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-cluster-autoscaler"></a> [aws-cluster-autoscaler](#module\_aws-cluster-autoscaler) | ./provisioning/kubernetes/cluster-autoscaler |  |
| <a name="module_aws-support"></a> [aws-support](#module\_aws-support) | ./provisioning/kubernetes/aws-support |  |
| <a name="module_certmanager"></a> [certmanager](#module\_certmanager) | ./provisioning/kubernetes/certmanager |  |
| <a name="module_consul"></a> [consul](#module\_consul) | ./provisioning/kubernetes/hashicorp-consul |  |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 13.2.1 |
| <a name="module_eks-vpc"></a> [eks-vpc](#module\_eks-vpc) | terraform-aws-modules/vpc/aws | ~> 2.66 |
| <a name="module_elastic-stack"></a> [elastic-stack](#module\_elastic-stack) | ./provisioning/kubernetes/elastic-stack |  |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./provisioning/kubernetes/grafana |  |
| <a name="module_kubernetes-dashboard"></a> [kubernetes-dashboard](#module\_kubernetes-dashboard) | ./provisioning/kubernetes/kubernetes-dashboard |  |
| <a name="module_namespaces"></a> [namespaces](#module\_namespaces) | ./provisioning/kubernetes/namespaces |  |
| <a name="module_nginx-controller-ingress"></a> [nginx-controller-ingress](#module\_nginx-controller-ingress) | ./provisioning/kubernetes/nginx-controller |  |
| <a name="module_vault"></a> [vault](#module\_vault) | ./provisioning/kubernetes/hashicorp-vault |  |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_vpc_endpoint.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_integer.cidr_priv_1](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_priv_2](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_priv_3](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_pub_1](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_pub_2](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_pub_3](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.cidr_vpc](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.my-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.my-auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [local_file.infrastructure-terraform-eks-version](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application Name | `string` | `"eks"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Tagged App Namespace | `any` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region for the VPC | `any` | n/a | yes |
| <a name="input_billingcustomer"></a> [billingcustomer](#input\_billingcustomer) | Which BILLINGCUSTOMER is setup in AWS | `any` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Cluster Version | `string` | `"1.18"` | no |
| <a name="input_enable_aws_vault_unseal"></a> [enable\_aws\_vault\_unseal](#input\_enable\_aws\_vault\_unseal) | If Vault is enabled and deployed, by default, the unseal process is manual; Changing this to true allows for automatic unseal using AWS KMS | `bool` | `false` | no |
| <a name="input_google_authDomain"></a> [google\_authDomain](#input\_google\_authDomain) | Used for Infrastructure OAuth: Google Auth Domain | `any` | n/a | yes |
| <a name="input_google_clientID"></a> [google\_clientID](#input\_google\_clientID) | Used for Infrastructure OAuth: Google Auth Client ID | `any` | n/a | yes |
| <a name="input_google_clientSecret"></a> [google\_clientSecret](#input\_google\_clientSecret) | Used for Infrastructure OAuth: Google Auth Client Secret | `any` | n/a | yes |
| <a name="input_helm_installations"></a> [helm\_installations](#input\_helm\_installations) | n/a | <pre>object({<br>    gitlab_runner = bool<br>    vault_consul  = bool<br>    ingress       = bool<br>    elasticstack  = bool<br>    grafana       = bool<br>  })</pre> | <pre>{<br>  "elasticstack": false,<br>  "gitlab_runner": false,<br>  "grafana": true,<br>  "ingress": true,<br>  "vault_consul": true<br>}</pre> | no |
| <a name="input_instance_desired_size"></a> [instance\_desired\_size](#input\_instance\_desired\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `8` | no |
| <a name="input_instance_max_size"></a> [instance\_max\_size](#input\_instance\_max\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `12` | no |
| <a name="input_instance_min_size"></a> [instance\_min\_size](#input\_instance\_min\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS Instance Type for provisioning | `string` | `"m5a.xlarge"` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Domain root where all kubernetes systems are orchestrating control | `any` | n/a | yes |
| <a name="input_root_vol_size"></a> [root\_vol\_size](#input\_root\_vol\_size) | Root Volume Size | `string` | `"50"` | no |
| <a name="input_tfenv"></a> [tfenv](#input\_tfenv) | Environment | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubecfg"></a> [kubecfg](#output\_kubecfg) | n/a |
| <a name="output_kubernetes-cluster-certificate-authority-data"></a> [kubernetes-cluster-certificate-authority-data](#output\_kubernetes-cluster-certificate-authority-data) | n/a |
| <a name="output_kubernetes-cluster-endpoint"></a> [kubernetes-cluster-endpoint](#output\_kubernetes-cluster-endpoint) | n/a |
| <a name="output_kubernetes-cluster-id"></a> [kubernetes-cluster-id](#output\_kubernetes-cluster-id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->