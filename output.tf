output "alb_hostname" {
  value = var.public_alb == true ? aws_lb.main_public[0].dns_name : aws_lb.main_private[0].dns_name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_discovery_namespace" {
  value = aws_service_discovery_private_dns_namespace.internal.id
}

output "alb_arn" {
  value = var.public_alb == true ? aws_lb.main_public[0].arn : aws_lb.main_private[0].arn
}

output "alb_listener_http_arn" {
  value = aws_lb_listener.http.arn
}

# output "alb_listener_https_redirect_arn" {
#   value = aws_lb_listener.front_end_https_http_redirect.arn
# }

output "ecs_task_security_group_ids" {
  value = [aws_security_group.ecs_tasks.id]
}

# output "ecs_access_role_arn" {
#   value = aws_iam_role.main.arn
# }

output "alb_dns_name" {
  value = var.public_alb == true ? aws_lb.main_public[0].dns_name : aws_lb.main_private[0].dns_name
}