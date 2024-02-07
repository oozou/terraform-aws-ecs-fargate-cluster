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

resource "aws_security_group_rule" "alb_ingress" {
  for_each = var.additional_security_group_alb_ingress_rules

  type              = "ingress"
  from_port         = lookup(each.value, "from_port", lookup(each.value, "port", null))
  to_port           = lookup(each.value, "to_port", lookup(each.value, "port", null))
  protocol          = lookup(each.value, "protocol", null)
  security_group_id = local.alb_aws_security_group_id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
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

  dynamic "access_logs" {
    for_each = var.alb_access_logs_bucket_name == "" ? [] : [true]
    content {
      bucket  = try(var.alb_access_logs_bucket_name, null)
      prefix  = "${local.cluster_name}-alb"
      enabled = var.is_enable_access_log
    }
  }

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
      content_type = var.default_fixed_response.content_type
      message_body = try(var.default_fixed_response.message_body, null)
      status_code  = try(var.default_fixed_response.status_code, null)
    }
    order = try(var.default_fixed_response.order, null)
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
  source  = "oozou/route53/aws"
  version = "1.0.2"

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
