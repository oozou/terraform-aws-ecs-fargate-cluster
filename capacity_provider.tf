resource "aws_ecs_capacity_provider" "this" {
  count = local.is_create_cp ? 1 : 0
  name = format("%s-cp", local.cluster_name)

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.capacity_provider_asg_config.asg_arn

    managed_scaling {
      target_capacity           = try(var.capacity_provider_asg_config.target_capacity, "100")
      maximum_scaling_step_size = try(var.capacity_provider_asg_config.maximum_scaling_step_size, "1")
      minimum_scaling_step_size = try(var.capacity_provider_asg_config.minimum_scaling_step_size, "1")
      status                    = "ENABLED"
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = local.is_create_cp ? 1 : 0
  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this[0].name]
  # capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this[0].name
  }
}