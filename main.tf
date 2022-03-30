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
/* ---------------------------- Assert condition ---------------------------- */
locals {
  assert_ecs_security_group_empty = var.is_create_ecs_task_security_group || (var.is_create_ecs_task_security_group == false && length(var.ecs_task_security_group_id) > 0) ? "pass" : file("Variable `ecs_task_security_group_id` is required when `is_create_ecs_task_security_group` is false")
  assert_alb_security_group_empty = var.is_create_alb_security_group || (var.is_create_alb_security_group == false && length(var.alb_aws_security_group_id) > 0) ? "pass" : file("Variable `alb_aws_security_group_id` is required when `is_create_alb_security_group` is false")
  assert_principle_empty          = var.is_create_role && length(var.allow_access_from_principals) > 0 ? "pass" : file("Variable `allow_access_from_principals` is required when `is_create_role` is true")
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
resource "aws_ecs_cluster" "this" {
  name = format("%s-cluster", local.cluster_name)

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

resource "aws_security_group_rule" "tasks_to_tasks_tcp" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  security_group_id = local.ecs_task_security_group_id

  source_security_group_id = local.ecs_task_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
}

resource "aws_security_group_rule" "tasks_to_tasks_udp" {
  count = var.is_create_ecs_task_security_group ? 1 : 0

  security_group_id = local.ecs_task_security_group_id

  source_security_group_id = local.ecs_task_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "udp"
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
# resource "aws_security_group_rule" "alb_to_tasks" {
#   count = var.is_create_ecs_task_security_group ? 1 : 0

#   security_group_id = local.ecs_task_security_group_id

#   source_security_group_id = aws_security_group.alb.id

#   type      = "ingress"
#   from_port = 0
#   to_port   = 65535
#   protocol  = "tcp"
# }

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
  count = var.is_create_alb_security_group ? 1 : 0

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

# TODO check if ness when not create self alb sg
# resource "aws_security_group_rule" "leaving_alb" {
#   count = var.is_create_alb_security_group ? 1 : 0

#   security_group_id        = local.alb_aws_security_group_id

#   source_security_group_id = local.ecs_task_security_group_id

#   type      = "egress"
#   from_port = 0
#   to_port   = 0
#   protocol  = -1
# }

/* -------------------------------------------------------------------------- */
/*                                     ALB                                    */
/* -------------------------------------------------------------------------- */
# Define the routing for the workloads
# Application Load Balancer Creation (ALB) in the DMZ
# resource "aws_lb" "main_public" {
#   count = var.is_public_alb ? 1 : 0

#   name                       = format("%s-alb", local.cluster_name)
#   load_balancer_type         = "application"
#   internal                   = false
#   subnets                    = var.public_subnet_ids
#   security_groups            = [aws_security_group.alb.id]
#   drop_invalid_header_fields = true
#   enable_deletion_protection = false

#   # access_logs {
#   #   bucket  = var.alb_access_logs_bucket
#   #   prefix  = "${var.account_alias}/${var.cluster_name}-alb"
#   #   enabled = true
#   # }

#   tags = merge(local.tags, { "Name" : format("%s-alb", local.cluster_name) })
# }

# resource "aws_lb" "main_private" {
#   count = var.is_public_alb == false ? 1 : 0

#   name                       = "${local.cluster_name}-internal-alb"
#   load_balancer_type         = "application"
#   internal                   = true
#   subnets                    = var.private_subnet_ids
#   security_groups            = [aws_security_group.alb.id]
#   drop_invalid_header_fields = true
#   enable_deletion_protection = false

#   # access_logs {
#   #   bucket  = var.alb_access_logs_bucket
#   #   prefix  = "${var.account_alias}/${var.cluster_name}-alb-internal"
#   #   enabled = true
#   # }

#   tags = merge({
#     Name = "${local.cluster_name}-alb-internal"
#   }, local.tags)
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = var.is_public_alb == false ? aws_lb.main_private[0].id : aws_lb.main_public[0].id

#   port            = var.alb_listener_port
#   protocol        = var.alb_listener_port == 443 ? "HTTPS" : "HTTP"
#   certificate_arn = var.alb_listener_port == 443 ? var.certificate_arn : ""
#   ssl_policy      = var.alb_listener_port == 443 ? "ELBSecurityPolicy-FS-1-2-Res-2019-08" : ""

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "No service found"
#       status_code  = "503"
#     }
#   }
# }

# resource "aws_lb_listener" "front_end_https_http_redirect" {
#   load_balancer_arn = var.is_public_alb == false ? aws_lb.main_private[0].id : aws_lb.main_public[0].id

#   port     = "80"
#   protocol = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

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
# For both internal and external use public hosted zone
# data "aws_route53_zone" "this" {
#   name         = var.route53_hosted_zone_name
#   private_zone = false
# }
# resource "aws_route53_record" "application" {
#   count = var.is_enable_friendly_dns_for_alb_endpoint ? 1 : 0

#   zone_id = data.aws_route53_zone.this.id
#   name    = var.fully_qualified_domain_name
#   type    = "A"

#   alias {
#     name                   = var.is_public_alb ? lower(aws_lb.main_public[0].dns_name) : lower(aws_lb.main_private[0].dns_name)
#     zone_id                = var.is_public_alb ? aws_lb.main_public[0].zone_id : aws_lb.main_private[0].zone_id
#     evaluate_target_health = true
#   }
# }

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

# NOTE This not require uncommented
# # events:ListTargetsByRule is required for ECS task to access subnet details from cloudwatch event rule.
# # This would be required in Gitlab CICD
# resource "aws_iam_role_policy" "main" {
#   name = "${local.cluster_name}-ecs-access-policy"
#   role = aws_iam_role.main.id

#   # need to provide ECS perimission only required to deploy image in CI/CD Gitlab pipeline
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "ecs:DescribeTaskDefinition",
#         "ecs:RegisterTaskDefinition",
#         "ecs:UpdateService",
#         "ecs:RunTask",
#         "iam:GetRole",
#         "iam:PassRole"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     },
#     {
#       "Action": [
#         "events:ListTargetsByRule"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF

# }
