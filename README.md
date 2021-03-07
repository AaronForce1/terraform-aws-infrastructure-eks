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
| terraform | >= 0.14.5 |
| aws | ~> 3.10 |
| gitlab | ~> 3.4 |
| helm | ~> 2.0 |
| kubernetes | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.10 |
| local | n/a |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aws-support | ./provisioning/kubernetes/aws-support |  |
| certmanager | ./provisioning/kubernetes/certmanager |  |
| consul | ./provisioning/kubernetes/hashicorp-consul |  |
| eks | terraform-aws-modules/eks/aws | ~> 13.2.1 |
| eks-vpc | terraform-aws-modules/vpc/aws | ~> 2.66 |
| kubernetes-dashboard | ./provisioning/kubernetes/kubernetes-dashboard |  |
| namespaces | ./provisioning/kubernetes/namespaces |  |
| nginx-controller-ingress | ./provisioning/kubernetes/nginx-controller |  |
| vault | ./provisioning/kubernetes/hashicorp-vault |  |

## Resources

| Name |
|------|
| [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) |
| [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) |
| [aws_eks_cluster_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) |
| [local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) |
| [random_integer](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | Application Name | `string` | `"eks"` | no |
| app\_namespace | Tagged App Namespace | `string` | `"technology-system"` | no |
| aws\_region | Region for the VPC | `any` | n/a | yes |
| billingcustomer | Which BILLINGCUSTOMER is setup in AWS | `string` | `"ticketflap"` | no |
| cluster\_version | Kubernetes Cluster Version | `string` | `"1.18"` | no |
| helm\_installations | n/a | <pre>object({<br>    vault_consul = bool<br>    ingress      = bool<br>  })</pre> | <pre>{<br>  "ingress": true,<br>  "vault_consul": true<br>}</pre> | no |
| instance\_desired\_size | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `8` | no |
| instance\_max\_size | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `12` | no |
| instance\_min\_size | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `2` | no |
| instance\_type | AWS Instance Type for provisioning | `string` | `"c5a.xlarge"` | no |
| key\_name | TF Key | `string` | `"INFRA-env-singapore-key"` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| root\_domain\_name | Domain root where all kubernetes systems are orchestrating control | `any` | n/a | yes |
| root\_vol\_size | Root Volume Size | `string` | `"50"` | no |
| tfenv | Environment | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| env-dynamic-url | n/a |
| kubecfg | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->