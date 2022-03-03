# terraform-aws-ecs-fargate-cluster

Terraform module with create ECS Cluster resources on AWS.
```terraform
module "ecs-fargate-cluster" {
  source = "./modules/fargate-cluster"

  prefix = "sbth"
  name = "app1"
  environment = "dev"

  custom_tags  =  { Workspace = "100-prefix-pass-app" }

  vpc_id             = "vpc-0736560f271b12fa3"
  public_subnet_ids  = ["subnet-01823d0de1ec69b7e","subnet-09dd147f9b90cadae"]
  private_subnet_ids = ["subnet-0b8e065bee1ab6d50","subnet-09ef78e7234432ce6"]

  allow_access_from_principals = ["arn:aws:iam::011275294601:root"]
  alb_listener_port            = 443

  fully_qualified_domain_name = "alb-test.sbth-oozou.millenium-m.me"
  route53_hosted_zone_name    = "sbth-oozou.millenium-m.me"

  certificate_arn                       = "arn:aws:acm:ap-southeast-1:011275294601:certificate/6115e039-c140-4c13-acc1-8668c038c205"
  enable_friendly_dns_for_alb_endpoint = true
  public_alb                           = true

}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lb.main_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.main_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.front_end_https_http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_route53_record.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_to_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.leaving_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_to_alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.tasks_to_tasks_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.tasks_to_tasks_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.tasks_to_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_private_dns_namespace.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_route53_zone.route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_listener_port"></a> [alb\_listener\_port](#input\_alb\_listener\_port) | The port to listen on the ALB for public services (80/443, default 443) | `number` | `443` | no |
| <a name="input_allow_access_from_principals"></a> [allow\_access\_from\_principals](#input\_allow\_access\_from\_principals) | A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster | `list(string)` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certitificate ARN to link with ALB | `string` | n/a | yes |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys | `map(any)` | `{}` | no |
| <a name="input_enable_friendly_dns_for_alb_endpoint"></a> [enable\_friendly\_dns\_for\_alb\_endpoint](#input\_enable\_friendly\_dns\_for\_alb\_endpoint) | Disable DNS mapping with ALB when used with AWS CDN, to route traffic to CDN. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_fully_qualified_domain_name"></a> [fully\_qualified\_domain\_name](#input\_fully\_qualified\_domain\_name) | The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS cluster to create | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets for container deployment | `list(string)` | n/a | yes |
| <a name="input_public_alb"></a> [public\_alb](#input\_public\_alb) | Flag for Internal/Public ALB. ALB is production env should be public | `bool` | `false` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets for AWS Application Load Balancer deployment | `list(string)` | n/a | yes |
| <a name="input_route53_hosted_zone_name"></a> [route53\_hosted\_zone\_name](#input\_route53\_hosted\_zone\_name) | The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to deploy the cluster in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | n/a |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | n/a |
| <a name="output_alb_hostname"></a> [alb\_hostname](#output\_alb\_hostname) | n/a |
| <a name="output_alb_listener_http_arn"></a> [alb\_listener\_http\_arn](#output\_alb\_listener\_http\_arn) | n/a |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | n/a |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | n/a |
| <a name="output_ecs_task_security_group_ids"></a> [ecs\_task\_security\_group\_ids](#output\_ecs\_task\_security\_group\_ids) | n/a |
| <a name="output_service_discovery_namespace"></a> [service\_discovery\_namespace](#output\_service\_discovery\_namespace) | n/a |
<!-- END_TF_DOCS -->
