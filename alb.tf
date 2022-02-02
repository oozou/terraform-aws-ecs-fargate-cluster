# Define the routing for the workloads
# Application Load Balancer Creation (ALB) in the DMZ
resource "aws_lb" "main_public" {
  count = var.public_alb == true ? 1 : 0

  name                       = "${var.cluster_name}-alb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.public_subnet_ids
  security_groups            = [aws_security_group.alb.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = true

  # access_logs {
  #   bucket  = var.alb_access_logs_bucket
  #   prefix  = "${var.account_alias}/${var.cluster_name}-alb"
  #   enabled = true
  # }

  tags = merge({
    Name = "${var.cluster_name}-alb"
  }, var.custom_tags)
}

resource "aws_lb" "main_private" {
  count = var.public_alb == false ? 1 : 0

  name                       = "${var.cluster_name}-alb-internal"
  load_balancer_type         = "application"
  internal                   = true
  subnets                    = var.private_subnet_ids
  security_groups            = [aws_security_group.alb.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  # access_logs {
  #   bucket  = var.alb_access_logs_bucket
  #   prefix  = "${var.account_alias}/${var.cluster_name}-alb-internal"
  #   enabled = true
  # }

  tags = merge({
    Name = "${var.cluster_name}-alb-internal"
  }, var.custom_tags)
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.public_alb == false ? aws_lb.main_private[0].id : aws_lb.main_public[0].id

  port            = var.alb_listener_port
  protocol        = var.alb_listener_port == 443 ? "HTTPS" : "HTTP"
  certificate_arn = var.alb_listener_port == 443 ? var.certificate_arn : ""
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

# resource "aws_lb_listener" "front_end_https_http_redirect" {
#   load_balancer_arn = var.public_alb == false ? aws_lb.main_private[0].id : aws_lb.main_public[0].id

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