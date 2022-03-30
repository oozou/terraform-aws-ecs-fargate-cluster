locals {
  cluster_name = "${var.prefix}-${var.environment}-${var.name}"

  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

resource "aws_ecs_cluster" "this" {
  name = format("%s-cluster", local.cluster_name)

  tags = merge(
    local.tags,
    { "Name" = format("%s-cluster", local.cluster_name) }
  )
}
