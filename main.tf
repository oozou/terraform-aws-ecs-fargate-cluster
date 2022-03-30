/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
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
/* ----------------------------- Raise exception ---------------------------- */
locals {
  assert_principle_empty = var.is_create_role && length(var.allow_access_from_principals) > 0 ? "pass" : file("Variable `allow_access_from_principals` is required when `is_create_role` is true")
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

# # events:ListTargetsByRule is required for ECS task to access subnet details from cloudwatch event rule.
# # This would be required in Gitlab CICD
# resource "aws_iam_role_policy" "main" {
#   name = "${local.cluster_name_name}-ecs-access-policy"
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
