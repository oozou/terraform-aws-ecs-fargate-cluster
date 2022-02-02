# resource "aws_iam_role" "main" {
#   name = "${var.cluster_name}-ecs-access-role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "AWS": ${jsonencode(var.allow_access_from_principals)}
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

#   tags = merge({
#     Name = "${var.cluster_name}-ecs-access-role"
#   }, var.custom_tags)
# }

# # events:ListTargetsByRule is required for ECS task to access subnet details from cloudwatch event rule.
# # This would be required in Gitlab CICD
# resource "aws_iam_role_policy" "main" {
#   name = "${var.cluster_name}-ecs-access-policy"
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