# ALB Security group
resource "aws_security_group" "alb" {
  name        = "${local.cluster_name}-alb-sg"
  description = "Access to the ALB"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "${local.cluster_name}-alb-sg"
  }, local.tags)
}

resource "aws_security_group_rule" "public_to_alb" {
  type        = "ingress"
  from_port   = var.alb_listener_port
  to_port     = var.alb_listener_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

# HTTP traffic is redirected to HTTPS
resource "aws_security_group_rule" "public_to_alb_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "leaving_alb" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = -1

  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}
