resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = merge({
    Name = var.cluster_name
  }, var.custom_tags)
}