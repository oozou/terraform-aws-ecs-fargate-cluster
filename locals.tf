/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
locals {
  cluster_name = "${var.prefix}-${var.environment}-${var.name}"

  ecs_task_security_group_id = var.is_create_ecs_task_security_group ? aws_security_group.ecs_tasks[0].id : var.ecs_task_security_group_id
  alb_aws_security_group_id  = var.is_create_alb_security_group ? aws_security_group.alb[0].id : var.alb_aws_security_group_id

  is_create_cp = var.capacity_provider_asg_config == null ? false : true

  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}
/* ----------------------------- Raise Condition ---------------------------- */
locals {
  raise_is_create_both_sg_group      = var.is_create_ecs_task_security_group != var.is_create_alb_security_group ? file("is_create_ecs_task_security_group and is_create_alb_security_group must equal") : "pass"
  raise_is_ecs_security_group_empty  = var.is_create_ecs_task_security_group == false && length(var.ecs_task_security_group_id) == 0 ? file("Variable `ecs_task_security_group_id` is required when `is_create_ecs_task_security_group` is false") : "pass"
  raise_is_alb_security_group_empty  = var.is_create_alb_security_group == false && length(var.alb_aws_security_group_id) == 0 ? file("Variable `alb_aws_security_group_id` is required when `is_create_alb_security_group` is false") : "pass"
  raise_is_public_subnet_ids_empty   = var.is_public_alb && length(var.public_subnet_ids) == 0 ? file("Variable `public_subnet_ids` is required when `is_public_alb` is true") : "pass"
  raise_is_private_subnet_ids_empty  = !var.is_public_alb && length(var.private_subnet_ids) == 0 ? file("Variable `private_subnet_ids` is required when `is_public_alb` is false") : "pass"
  raise_is_http_security             = var.is_ignore_unsecured_connection == false && var.alb_listener_port == 80 ? file("This will expose the alb as public on port http 80") : "pass"
  raise_is_alb_certificate_arn_empty = var.is_create_alb && var.alb_listener_port == 443 && length(var.alb_certificate_arn) == 0 ? file("Variable `alb_certificate_arn` is required when `is_create_alb` is true and `alb_listener_port` == 443") : "pass"
  raise_is_principle_empty           = var.is_create_role && length(var.allow_access_from_principals) == 0 ? file("Variable `allow_access_from_principals` is required when `is_create_role` is true") : "pass"
  raise_is_hoste_zone_empty          = var.is_create_alb && var.is_create_alb_dns_record && length(var.route53_hosted_zone_name) == 0 ? file("`route53_hosted_zone_name` is required to create alb alias record") : "pass"
  raise_is_alb_domain_name_empty     = var.is_create_alb && var.is_create_alb_dns_record && length(var.fully_qualified_domain_name) == 0 ? file("`fully_qualified_domain_name` is required to create alb alias record") : "pass"
}
