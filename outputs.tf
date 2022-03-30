# output "alb_hostname" {
#   description = ""
#   value       = var.public_alb == true ? aws_lb.main_public[0].dns_name : aws_lb.main_private[0].dns_name
# }

output "ecs_cluster_arn" {
  description = "ARN that identifies the cluster."
  value       = aws_ecs_cluster.this.arn
}

output "ecs_cluster_id" {
  description = "ID that identifies the cluster."
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "Name of the cluster"
  value       = aws_ecs_cluster.this.name
}

# output "service_discovery_namespace" {
#   description = ""
#   value       = aws_service_discovery_private_dns_namespace.internal.id
# }

# output "alb_arn" {
#   description = ""
#   value       = var.public_alb == true ? aws_lb.main_public[0].arn : aws_lb.main_private[0].arn
# }

# output "alb_listener_http_arn" {
#   description = ""
#   value       = aws_lb_listener.http.arn
# }

# # output "alb_listener_https_redirect_arn" {
# #   description = ""
# #   value = aws_lb_listener.front_end_https_http_redirect.arn
# # }

# output "ecs_task_security_group_ids" {
#   description = ""
#   value       = [aws_security_group.ecs_tasks.id]
# }

# # output "ecs_access_role_arn" {
# #   description = ""
# #   value = aws_iam_role.main.arn
# # }

# output "alb_dns_name" {
#   description = ""
#   value       = var.public_alb == true ? aws_lb.main_public[0].dns_name : aws_lb.main_private[0].dns_name
# }
