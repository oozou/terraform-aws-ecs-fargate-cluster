locals {
  environment  = var.environment
  cluster_name = "${var.prefix}-${var.environment}-${var.name}"

  tags = merge(
    {
      "Environment" = local.environment,
      "Terraform"   = "true"
    },
    var.custom_tags
  )
}

resource "aws_ecs_cluster" "main" {
  name = "${local.cluster_name}-cluster"

  tags = merge({
    Name = local.cluster_name
  }, local.tags)
}
