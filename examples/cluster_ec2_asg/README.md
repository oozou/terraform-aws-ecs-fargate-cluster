<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fargate_cluster"></a> [fargate\_cluster](#module\_fargate\_cluster) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | ARN of ssl in the ACM | `string` | n/a | yes |
| <a name="input_generics_info"></a> [generics\_info](#input\_generics\_info) | Generic infomation | <pre>object({<br>    region      = string<br>    prefix      = string<br>    environment = string<br>    name        = string<br>    custom_tags = map(any)<br>  })</pre> | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy | `string` | n/a | yes |
| <a name="input_allow_access_from_principals"></a> [allow\_access\_from\_principals](#input\_allow\_access\_from\_principals) | A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
