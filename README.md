# infrastructure-terraform-eks

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.5 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | ~> 3.4 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.13.0 |
| <a name="provider_aws.secondary"></a> [aws.secondary](#provider\_aws.secondary) | 4.13.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.11.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./provisioning/kubernetes/argocd | n/a |
| <a name="module_aws-cluster-autoscaler"></a> [aws-cluster-autoscaler](#module\_aws-cluster-autoscaler) | ./aws-cluster-autoscaler | n/a |
| <a name="module_aws-support"></a> [aws-support](#module\_aws-support) | ./aws-support | n/a |
| <a name="module_certmanager"></a> [certmanager](#module\_certmanager) | ./provisioning/kubernetes/certmanager | n/a |
| <a name="module_consul"></a> [consul](#module\_consul) | ./provisioning/kubernetes/hashicorp-consul | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 18.23.0 |
| <a name="module_eks-vpc"></a> [eks-vpc](#module\_eks-vpc) | terraform-aws-modules/vpc/aws | ~> 3.14 |
| <a name="module_eks-vpc-endpoints"></a> [eks-vpc-endpoints](#module\_eks-vpc-endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 3.14 |
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | terraform-aws-modules/eks/aws//modules/eks-managed-node-group | ~> 18.23.0 |
| <a name="module_elastic-stack"></a> [elastic-stack](#module\_elastic-stack) | ./provisioning/kubernetes/elastic-stack | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./provisioning/kubernetes/grafana | n/a |
| <a name="module_kubernetes-dashboard"></a> [kubernetes-dashboard](#module\_kubernetes-dashboard) | ./provisioning/kubernetes/kubernetes-dashboard | n/a |
| <a name="module_nginx-controller-ingress"></a> [nginx-controller-ingress](#module\_nginx-controller-ingress) | ./provisioning/kubernetes/nginx-controller | n/a |
| <a name="module_subnet_addrs"></a> [subnet\_addrs](#module\_subnet\_addrs) | hashicorp/subnets/cidr | 1.0.0 |
| <a name="module_vault"></a> [vault](#module\_vault) | ./provisioning/kubernetes/hashicorp-vault | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.node_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_route53_zone.hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_vpc_endpoint.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [kubectl_manifest.aws-auth](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [random_integer.cidr_vpc](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_availability_zones.available_azs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [local_file.infrastructure-terraform-eks-version](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application Name | `string` | `"eks"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Tagged App Namespace | `any` | n/a | yes |
| <a name="input_aws_installations"></a> [aws\_installations](#input\_aws\_installations) | AWS Support Components including Cluster Autoscaler, EBS/EFS Storage Classes, etc. | <pre>object({<br>    storage_ebs = optional(object({<br>      eks_irsa_role = bool<br>      gp2           = bool<br>      gp3           = bool<br>      st1           = bool<br>    }))<br>    storage_efs = optional(object({<br>      eks_irsa_role       = bool<br>      eks_security_groups = bool<br>      efs                 = bool<br>    }))<br>    cluster_autoscaler   = optional(bool)<br>    route53_external_dns = optional(bool)<br>    kms_secrets_access   = optional(bool)<br>    cert_manager         = optional(bool)<br>  })</pre> | <pre>{<br>  "cert_manager": true,<br>  "cluster_autoscaler": true,<br>  "kms_secrets_access": true,<br>  "route53_external_dns": true,<br>  "storage_ebs": {<br>    "eks_irsa_role": true,<br>    "gp2": true,<br>    "gp3": true,<br>    "st1": true<br>  },<br>  "storage_efs": {<br>    "efs": true,<br>    "eks_irsa_role": true,<br>    "eks_security_groups": true<br>  }<br>}</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region for all primary configurations | `any` | n/a | yes |
| <a name="input_aws_secondary_region"></a> [aws\_secondary\_region](#input\_aws\_secondary\_region) | Secondary Region for certain redundant AWS components | `any` | n/a | yes |
| <a name="input_billingcustomer"></a> [billingcustomer](#input\_billingcustomer) | Which Billingcustomer, aka Cost Center, is responsible for this infra provisioning | `any` | n/a | yes |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | An add-on is software that provides supporting operational capabilities to Kubernetes applications, but is not specific to the application: coredns, kube-proxy, vpc-cni | `any` | <pre>{<br>  "coredns": {<br>    "resolve_conflicts": "OVERWRITE"<br>  },<br>  "kube-proxy": {},<br>  "vpc-cni": {<br>    "resolve_conflicts": "OVERWRITE"<br>  }<br>}</pre> | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | If the cluster endpoint is to be exposed to the public internet, specify CIDRs here that it should be restricted to | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Optional override for cluster name instead of standard {name}-{namespace}-{env} | `string` | `""` | no |
| <a name="input_cluster_root_domain"></a> [cluster\_root\_domain](#input\_cluster\_root\_domain) | Domain root where all kubernetes systems are orchestrating control | <pre>object({<br>    create          = optional(bool)<br>    name            = string<br>    ingress_records = optional(list(string))<br>  })</pre> | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Cluster Version | `string` | `"1.21"` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | enable launch template on node group | `bool` | `false` | no |
| <a name="input_custom_aws_s3_support_infra"></a> [custom\_aws\_s3\_support\_infra](#input\_custom\_aws\_s3\_support\_infra) | Adding the ability to provision additional support infrastructure required for certain EKS Helm chart/App-of-App Components | <pre>list(object({<br>    name                                 = string<br>    bucket_acl                           = string<br>    aws_kms_key_id                       = optional(string)<br>    lifecycle_rules                      = any<br>    versioning                           = bool<br>    k8s_namespace_service_account_access = any<br>  }))</pre> | `[]` | no |
| <a name="input_custom_namespaces"></a> [custom\_namespaces](#input\_custom\_namespaces) | Adding namespaces to a default cluster provisioning process | `list(string)` | `[]` | no |
| <a name="input_default_ami_type"></a> [default\_ami\_type](#input\_default\_ami\_type) | Default AMI used for node provisioning | `string` | `"AL2_x86_64"` | no |
| <a name="input_default_capacity_type"></a> [default\_capacity\_type](#input\_default\_capacity\_type) | Default capacity configuraiton used for node provisioning. Valid values: `ON_DEMAND, SPOT` | `string` | `"ON_DEMAND"` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Override default 'single nodegroup, on a private subnet' with more advaned configuration archetypes | `any` | `[]` | no |
| <a name="input_elastic_ip_custom_configuration"></a> [elastic\_ip\_custom\_configuration](#input\_elastic\_ip\_custom\_configuration) | By default, this module will provision new Elastic IPs for the VPC's NAT Gateways; however, one can also override and specify separate, pre-existing elastic IPs as needed in order to preserve IPs that are whitelisted; reminder that the list of EIPs should have the same count as nat gateways created. | <pre>object({<br>    enabled             = bool<br>    reuse_nat_ips       = optional(bool)<br>    external_nat_ip_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "external_nat_ip_ids": [],<br>  "reuse_nat_ips": false<br>}</pre> | no |
| <a name="input_google_authDomain"></a> [google\_authDomain](#input\_google\_authDomain) | Used for Infrastructure OAuth: Google Auth Domain | `any` | n/a | yes |
| <a name="input_google_clientID"></a> [google\_clientID](#input\_google\_clientID) | Used for Infrastructure OAuth: Google Auth Client ID | `any` | n/a | yes |
| <a name="input_google_clientSecret"></a> [google\_clientSecret](#input\_google\_clientSecret) | Used for Infrastructure OAuth: Google Auth Client Secret | `any` | n/a | yes |
| <a name="input_helm_configurations"></a> [helm\_configurations](#input\_helm\_configurations) | n/a | <pre>object({<br>    dashboard     = optional(string)<br>    gitlab_runner = optional(string)<br>    vault_consul = optional(object({<br>      consul_values           = optional(string)<br>      vault_values            = optional(string)<br>      enable_aws_vault_unseal = optional(bool)   # If Vault is enabled and deployed, by default, the unseal process is manual; Changing this to true allows for automatic unseal using AWS KMS"<br>      vault_nodeselector      = optional(string) # Allow for vault node selectors without extensive reconfiguration of the standard values file<br>    }))<br>    ingress = optional(object({<br>      nginx_values       = optional(string)<br>      certmanager_values = optional(string)<br>    }))<br>    elasticstack = optional(string)<br>    grafana      = optional(string)<br>    argocd = optional(object({<br>      value_file      = optional(string)<br>      application_set = optional(list(string))<br>      repository_secrets = optional(list(object({<br>        name          = string<br>        url           = string<br>        type          = string<br>        username      = string<br>        password      = string<br>        secrets_store = string<br>      })))<br>      credential_templates = optional(list(object({<br>        name          = string<br>        url           = string<br>        username      = string<br>        password      = string<br>        secrets_store = string<br>      })))<br>      generate_plugin_repository_secret = optional(bool)<br>    }))<br>  })</pre> | <pre>{<br>  "argocd": null,<br>  "dashboard": null,<br>  "elasticstack": null,<br>  "gitlab_runner": null,<br>  "grafana": null,<br>  "ingress": null,<br>  "vault_consul": null<br>}</pre> | no |
| <a name="input_helm_installations"></a> [helm\_installations](#input\_helm\_installations) | n/a | <pre>object({<br>    dashboard     = bool<br>    gitlab_runner = bool<br>    vault_consul  = bool<br>    ingress       = bool<br>    elasticstack  = bool<br>    grafana       = bool<br>    argocd        = bool<br>  })</pre> | <pre>{<br>  "argocd": false,<br>  "dashboard": true,<br>  "elasticstack": false,<br>  "gitlab_runner": false,<br>  "grafana": true,<br>  "ingress": true,<br>  "vault_consul": true<br>}</pre> | no |
| <a name="input_instance_desired_size"></a> [instance\_desired\_size](#input\_instance\_desired\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `2` | no |
| <a name="input_instance_max_size"></a> [instance\_max\_size](#input\_instance\_max\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `4` | no |
| <a name="input_instance_min_size"></a> [instance\_min\_size](#input\_instance\_min\_size) | Count of instances to be spun up within the context of a kubernetes cluster. Minimum: 2 | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS Instance Type for provisioning | `string` | `"c5a.medium"` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_nat_gateway_custom_configuration"></a> [nat\_gateway\_custom\_configuration](#input\_nat\_gateway\_custom\_configuration) | Override the default NAT Gateway configuration, which configures a single NAT gateway for non-prod, while one per AZ on tfenv=prod | <pre>object({<br>    enabled                           = bool<br>    enable_nat_gateway                = bool<br>    enable_dns_hostnames              = bool<br>    single_nat_gateway                = bool<br>    one_nat_gateway_per_az            = bool<br>    enable_vpn_gateway                = bool<br>    propagate_public_route_tables_vgw = bool<br>  })</pre> | <pre>{<br>  "enable_dns_hostnames": true,<br>  "enable_nat_gateway": true,<br>  "enable_vpn_gateway": false,<br>  "enabled": false,<br>  "one_nat_gateway_per_az": true,<br>  "propagate_public_route_tables_vgw": false,<br>  "single_nat_gateway": false<br>}</pre> | no |
| <a name="input_node_key_name"></a> [node\_key\_name](#input\_node\_key\_name) | EKS Node Key Name | `string` | `""` | no |
| <a name="input_node_public_ip"></a> [node\_public\_ip](#input\_node\_public\_ip) | assign public ip on the nodes | `bool` | `false` | no |
| <a name="input_operator_domain_name"></a> [operator\_domain\_name](#input\_operator\_domain\_name) | Domain root of operator cluster | `string` | `""` | no |
| <a name="input_root_vol_size"></a> [root\_vol\_size](#input\_root\_vol\_size) | Root Volume Size | `string` | `"50"` | no |
| <a name="input_tfenv"></a> [tfenv](#input\_tfenv) | Environment | `any` | n/a | yes |
| <a name="input_vpc_flow_logs"></a> [vpc\_flow\_logs](#input\_vpc\_flow\_logs) | Manually enable or disable VPC flow logs; Please note, for production, these are enabled by default otherwise they will be disabled; setting a value for this object will override all defaults regardless of environment | `map` | `{}` | no |
| <a name="input_vpc_subnet_configuration"></a> [vpc\_subnet\_configuration](#input\_vpc\_subnet\_configuration) | Configure VPC CIDR and relative subnet intervals for generating a VPC. If not specified, default values will be generated. | <pre>object({<br>    base_cidr = string<br>    subnet_bit_interval = object({<br>      public  = number<br>      private = number<br>    })<br>    autogenerate = optional(bool)<br>  })</pre> | <pre>{<br>  "autogenerate": true,<br>  "base_cidr": "172.%s.0.0/16",<br>  "subnet_bit_interval": {<br>    "private": 6,<br>    "public": 2<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_base_cidr_block"></a> [base\_cidr\_block](#output\_base\_cidr\_block) | n/a |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | n/a |
| <a name="output_kubernetes-cluster-auth"></a> [kubernetes-cluster-auth](#output\_kubernetes-cluster-auth) | n/a |
| <a name="output_kubernetes-cluster-certificate-authority-data"></a> [kubernetes-cluster-certificate-authority-data](#output\_kubernetes-cluster-certificate-authority-data) | output "kubecfg" { value = module.eks.kubeconfig } |
| <a name="output_kubernetes-cluster-endpoint"></a> [kubernetes-cluster-endpoint](#output\_kubernetes-cluster-endpoint) | n/a |
| <a name="output_kubernetes-cluster-id"></a> [kubernetes-cluster-id](#output\_kubernetes-cluster-id) | n/a |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | # ----------- # MODULE: VPC # ----------- |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->