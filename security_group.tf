resource "aws_security_group" "ecs_tasks" {
  name   = "${var.cluster_name}-sg-ecs-tasks"
  vpc_id = var.vpc_id

  tags = merge({
    Name = "${var.cluster_name}-sg-ecs-tasks"
  }, var.custom_tags)
}

resource "aws_security_group_rule" "tasks_to_tasks_tcp" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "tasks_to_tasks_udp" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  security_group_id        = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

# We want all Fargate traffic to come from the ALB and within the subnet
# We aren't locking down ports but that it must come from ALB
resource "aws_security_group_rule" "alb_to_tasks" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "tasks_to_world" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks.id
}
