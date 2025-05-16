# terraform-aws-ecs-fargate-cluster

Terraform module with create ECS Cluster resources on AWS.

```terraform
Please see at `examples/simple`
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.00 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_alb"></a> [application\_alb](#module\_application\_alb) | oozou/alb/aws | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_to_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.tasks_to_tasks_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.tasks_to_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_managed_policy_arns"></a> [additional\_managed\_policy\_arns](#input\_additional\_managed\_policy\_arns) | Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed\_policy\_arns = []) will cause Terraform to remove all managed policy attachments. | `list(string)` | `[]` | no |
| <a name="input_additional_security_group_alb_ingress_rules"></a> [additional\_security\_group\_alb\_ingress\_rules](#input\_additional\_security\_group\_alb\_ingress\_rules) | Map of ingress and any specific/overriding attributes to be created | `any` | `{}` | no |
| <a name="input_additional_security_group_ingress_rules"></a> [additional\_security\_group\_ingress\_rules](#input\_additional\_security\_group\_ingress\_rules) | Map of ingress and any specific/overriding attributes to be created | `any` | `{}` | no |
| <a name="input_alb_access_logs_bucket_name"></a> [alb\_access\_logs\_bucket\_name](#input\_alb\_access\_logs\_bucket\_name) | ALB access\_logs S3 bucket name. | `string` | `""` | no |
| <a name="input_alb_aws_security_group_id"></a> [alb\_aws\_security\_group\_id](#input\_alb\_aws\_security\_group\_id) | (Require) when is\_create\_alb\_security\_group is set to `false` | `string` | `""` | no |
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | Certitificate ARN to link with ALB | `string` | `""` | no |
| <a name="input_alb_listener_port"></a> [alb\_listener\_port](#input\_alb\_listener\_port) | The port to listen on the ALB for public services (80/443, default 443) | `number` | `443` | no |
| <a name="input_alb_s3_access_principals"></a> [alb\_s3\_access\_principals](#input\_alb\_s3\_access\_principals) | n/a | <pre>list(object({<br>    type        = string<br>    identifiers = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_allow_access_from_principals"></a> [allow\_access\_from\_principals](#input\_allow\_access\_from\_principals) | A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster | `list(string)` | `[]` | no |
| <a name="input_capacity_provider_asg_config"></a> [capacity\_provider\_asg\_config](#input\_capacity\_provider\_asg\_config) | Auto scaling group arn for capacity provider EC2 | `map(any)` | `null` | no |
| <a name="input_default_fixed_response"></a> [default\_fixed\_response](#input\_default\_fixed\_response) | Map of listener default fixed response | `any` | <pre>{<br>  "content_type": "text/plain",<br>  "message_body": "No service found",<br>  "order": null,<br>  "status_code": 503<br>}</pre> | no |
| <a name="input_ecs_task_security_group_id"></a> [ecs\_task\_security\_group\_id](#input\_ecs\_task\_security\_group\_id) | (Require) when is\_create\_alb\_security\_group is set to `false` | `string` | `""` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_fully_qualified_domain_name"></a> [fully\_qualified\_domain\_name](#input\_fully\_qualified\_domain\_name) | The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com | `string` | `""` | no |
| <a name="input_is_create_alb"></a> [is\_create\_alb](#input\_is\_create\_alb) | Whether to create alb or not | `bool` | `true` | no |
| <a name="input_is_create_alb_dns_record"></a> [is\_create\_alb\_dns\_record](#input\_is\_create\_alb\_dns\_record) | Whether to create ALB dns record or not | `bool` | `true` | no |
| <a name="input_is_create_alb_security_group"></a> [is\_create\_alb\_security\_group](#input\_is\_create\_alb\_security\_group) | Whether to create ALB security group or not | `bool` | `true` | no |
| <a name="input_is_create_discovery_namespace"></a> [is\_create\_discovery\_namespace](#input\_is\_create\_discovery\_namespace) | Flag to determine whether to create a discovery namespace | `bool` | `true` | no |
| <a name="input_is_create_ecs_task_security_group"></a> [is\_create\_ecs\_task\_security\_group](#input\_is\_create\_ecs\_task\_security\_group) | Whether to create ECS tasks security group or not | `bool` | `true` | no |
| <a name="input_is_create_role"></a> [is\_create\_role](#input\_is\_create\_role) | Whether to create ecs role or not | `bool` | `true` | no |
| <a name="input_is_enable_access_log"></a> [is\_enable\_access\_log](#input\_is\_enable\_access\_log) | Boolean to enable / disable access\_logs. Defaults to false, even when bucket is specified. | `bool` | `false` | no |
| <a name="input_is_enable_container_insights"></a> [is\_enable\_container\_insights](#input\_is\_enable\_container\_insights) | Whether to be used to enable CloudWatch Container Insights for a cluster. | `bool` | `true` | no |
| <a name="input_is_ignore_unsecured_connection"></a> [is\_ignore\_unsecured\_connection](#input\_is\_ignore\_unsecured\_connection) | Whether to by pass the HTTPs endpoints required or not | `bool` | `false` | no |
| <a name="input_is_public_alb"></a> [is\_public\_alb](#input\_is\_public\_alb) | Flag for Internal/Public ALB. ALB is production env should be public | `bool` | `false` | no |
| <a name="input_listener_https_fixed_response"></a> [listener\_https\_fixed\_response](#input\_listener\_https\_fixed\_response) | Have the HTTPS listener return a fixed response for the default action. | <pre>object({<br>    content_type = string<br>    message_body = string<br>    status_code  = string<br>  })</pre> | <pre>{<br>  "content_type": "text/plain",<br>  "message_body": "No service found",<br>  "status_code": "404"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS cluster to create | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets for container deployment | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets for AWS Application Load Balancer deployment | `list(string)` | `[]` | no |
| <a name="input_route53_hosted_zone_name"></a> [route53\_hosted\_zone\_name](#input\_route53\_hosted\_zone\_name) | The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud | `string` | `""` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The SSL policy for the ALB listener when using HTTPS | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to deploy the cluster in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of alb |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | ID of alb |
| <a name="output_alb_listener_http_arn"></a> [alb\_listener\_http\_arn](#output\_alb\_listener\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_alb_listener_https_redirect_arn"></a> [alb\_listener\_https\_redirect\_arn](#output\_alb\_listener\_https\_redirect\_arn) | ARN of the listener (matches id). |
| <a name="output_capacity_provider_name"></a> [capacity\_provider\_name](#output\_capacity\_provider\_name) | Name of capacity provider. |
| <a name="output_ecs_access_role_arn"></a> [ecs\_access\_role\_arn](#output\_ecs\_access\_role\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN that identifies the cluster. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID that identifies the cluster. |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the cluster |
| <a name="output_ecs_task_security_group_id"></a> [ecs\_task\_security\_group\_id](#output\_ecs\_task\_security\_group\_id) | ID of the security group rule. |
| <a name="output_service_discovery_namespace"></a> [service\_discovery\_namespace](#output\_service\_discovery\_namespace) | The ID of a namespace. |
<!-- END_TF_DOCS -->
