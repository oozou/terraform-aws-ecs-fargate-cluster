/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
locals {
  cluster_name = "${var.prefix}-${var.environment}-${var.name}"

  ecs_task_security_group_id = var.is_create_ecs_task_security_group ? aws_security_group.ecs_tasks[0].id : var.ecs_task_security_group_id
  alb_aws_security_group_id  = var.is_create_alb_security_group ? aws_security_group.alb[0].id : var.alb_aws_security_group_id

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
/*                             ALB Security Group                             */
/* -------------------------------------------------------------------------- */
resource "aws_security_group" "alb" {
  count = var.is_create_alb_security_group ? 1 : 0

  name        = format("%s-alb-sg", local.cluster_name)
  description = format("Security group for ALB %s-alb", local.cluster_name)
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { "Name" = format("%s-alb-sg", local.cluster_name) })
}

resource "aws_security_group_rule" "public_to_alb" {
  count = var.is_create_alb_security_group && var.alb_listener_port == 443 ? 1 : 0

  security_group_id = local.alb_aws_security_group_id

  type        = "ingress"
  from_port   = var.alb_listener_port
  to_port     = var.alb_listener_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_to_alb_http" {
  count = var.is_create_alb_security_group ? 1 : 0

  security_group_id = local.alb_aws_security_group_id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "leaving_alb" {
  count = var.is_create_alb_security_group ? 1 : 0

  security_group_id = local.alb_aws_security_group_id

  source_security_group_id = local.ecs_task_security_group_id

  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = -1
}

/* -------------------------------------------------------------------------- */
/*                                     ALB                                    */
/* -------------------------------------------------------------------------- */
# Define the routing for the workloads
# Application Load Balancer Creation (ALB) in the DMZ
resource "aws_lb" "this" {
  count = var.is_create_alb ? 1 : 0

  name                       = var.is_public_alb ? format("%s-alb", local.cluster_name) : format("%s-internal-alb", local.cluster_name)
  load_balancer_type         = "application"
  internal                   = !var.is_public_alb
  subnets                    = var.is_public_alb ? var.public_subnet_ids : var.private_subnet_ids
  security_groups            = [local.alb_aws_security_group_id]
  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  # access_logs {
  #   bucket  = var.alb_access_logs_bucket
  #   prefix  = "${var.account_alias}/${var.cluster_name}-alb"
  #   enabled = true
  # }

  tags = merge(local.tags, { "Name" : var.is_public_alb ? format("%s-alb", local.cluster_name) : format("%s-internal-alb", local.cluster_name) })
}

resource "aws_lb_listener" "http" {
  count = var.is_create_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].id

  port            = var.alb_listener_port
  protocol        = var.alb_listener_port == 443 ? "HTTPS" : "HTTP"
  certificate_arn = var.alb_listener_port == 443 ? var.alb_certificate_arn : ""
  ssl_policy      = var.alb_listener_port == 443 ? "ELBSecurityPolicy-FS-1-2-Res-2019-08" : ""

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No service found"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "front_end_https_http_redirect" {
  # If not var.alb_listener_port == 443, the listener rule will overlap and raise error
  count = var.is_create_alb && var.alb_listener_port == 443 ? 1 : 0

  depends_on = [
    aws_lb_listener.http
  ]

  load_balancer_arn = aws_lb.this[0].id

  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                                     DNS                                    */
/* -------------------------------------------------------------------------- */
# Setup DNS discovery
resource "aws_service_discovery_private_dns_namespace" "internal" {
  # This name does not follow convention because it is used as part of the domain name
  name        = "${local.cluster_name}.internal"
  description = "Service Discovery for internal communcation for ${local.cluster_name} ECS cluster"
  vpc         = var.vpc_id

  tags = merge(local.tags, { "Name" : format("%s.internal", local.cluster_name) })
}

# /* --------------------------------- Route53 -------------------------------- */
module "application_record" {
  source = "git::ssh://git@github.com/oozou/terraform-aws-route53.git?ref=v1.0.0"

  count = var.is_create_alb && var.is_create_alb_dns_record ? 1 : 0

  is_create_zone = false
  is_public_zone = true # Default `true`

  prefix      = var.prefix
  environment = var.environment

  dns_name = var.route53_hosted_zone_name

  dns_records = {
    application_record = {
      name = replace(var.fully_qualified_domain_name, ".${var.route53_hosted_zone_name}", "") # Auto append with dns_name
      type = "A"

      alias = {
        name                   = aws_lb.this[0].dns_name # Target DNS name
        zone_id                = aws_lb.this[0].zone_id
        evaluate_target_health = true
      }
    }
  }
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
