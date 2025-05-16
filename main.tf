/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
resource "aws_ecs_cluster" "this" {
  name = format("%s-cluster", local.cluster_name)

  dynamic "setting" {
    for_each = var.is_enable_container_insights ? [true] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  tags = merge(
    local.tags,
    { "Name" = format("%s-cluster", local.cluster_name) }
  )
}

/* -------------------------------------------------------------------------- */
/*                             ECS Security Group                             */
/* -------------------------------------------------------------------------- */
resource "aws_security_group" "ecs_tasks" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  name        = format("%s-ecs-tasks-sg", local.cluster_name)
  description = format("Security group for ECS task %s-ecs-tasks-sg", local.cluster_name)
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { "Name" = format("%s-ecs-tasks-sg", local.cluster_name) })
}

resource "aws_security_group_rule" "ecs_tasks_ingress" {
  for_each = var.additional_security_group_ingress_rules

  type              = "ingress"
  from_port         = lookup(each.value, "from_port", lookup(each.value, "port", null))
  to_port           = lookup(each.value, "to_port", lookup(each.value, "port", null))
  protocol          = lookup(each.value, "protocol", null)
  security_group_id = local.ecs_task_security_group_id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

resource "aws_security_group_rule" "tasks_to_tasks_all" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  security_group_id = local.ecs_task_security_group_id

  source_security_group_id = local.ecs_task_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"
}

resource "aws_security_group_rule" "tasks_to_world" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  security_group_id = local.ecs_task_security_group_id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# We want all Fargate traffic to come from the ALB and within the subnet
# We aren't locking down ports but that it must come from ALB
resource "aws_security_group_rule" "alb_to_tasks" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  security_group_id = local.ecs_task_security_group_id

  source_security_group_id = local.alb_aws_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
}

/* -------------------------------------------------------------------------- */
/*                                      ALB                                   */
/* -------------------------------------------------------------------------- */
module "application_alb" {
  # source  = "oozou/alb/aws"
  # version = "1.0.0"
  source = "git::ssh://git@github.com/oozou/terraform-aws-alb.git?ref=main"

  count = var.is_create_alb ? 1 : 0
  # This module is used to create an ALB and its associated resources
  prefix                                      = var.prefix
  environment                                 = var.environment
  name                                        = var.name
  tags                                        = var.tags
  vpc_id                                      = var.vpc_id
  public_subnet_ids                           = var.public_subnet_ids
  private_subnet_ids                          = var.private_subnet_ids
  is_public_alb                               = var.is_public_alb
  is_create_alb_security_group                = var.is_create_alb_security_group
  is_create_alb_dns_record                    = var.is_create_alb_dns_record
  is_enable_access_log                        = var.is_enable_access_log
  alb_listener_port                           = var.alb_listener_port
  alb_certificate_arn                         = var.alb_certificate_arn
  ssl_policy                                  = var.ssl_policy
  enable_deletion_protection                  = var.enable_deletion_protection
  additional_security_group_alb_ingress_rules = var.additional_security_group_alb_ingress_rules
  alb_s3_access_principals                    = var.alb_s3_access_principals
  alb_access_logs_bucket_name                 = var.alb_access_logs_bucket_name
  listener_https_fixed_response               = var.listener_https_fixed_response
  is_create_discovery_namespace               = var.is_create_discovery_namespace

  route53_hosted_zone_name    = var.route53_hosted_zone_name
  fully_qualified_domain_name = var.fully_qualified_domain_name
}

/* -------------------------------------------------------------------------- */
/*                                  IAM Role                                  */
/* -------------------------------------------------------------------------- */
resource "aws_iam_role" "this" {
  count = var.is_create_role ? 1 : 0

  name = format("%s-ecs-access-role", local.cluster_name)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.allow_access_from_principals
        }
      },
    ]
  })

  managed_policy_arns = var.additional_managed_policy_arns

  tags = merge(local.tags, { "Name" : format("%s-ecs-access-role", local.cluster_name) })
}
