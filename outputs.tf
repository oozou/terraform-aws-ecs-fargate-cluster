/* ------------------------------- ECS Cluster ------------------------------ */
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
/* ----------------------------- Security Group ----------------------------- */
output "ecs_task_security_group_id" {
  description = "ID of the security group rule."
  value       = element(concat(aws_security_group.ecs_tasks[*].id, [""]), 0)
}
/* -------------------------------- IAM Role -------------------------------- */
output "ecs_access_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = element(concat(aws_iam_role.this[*].arn, [""]), 0)
}
/* ----------------------------------- ALB ---------------------------------- */
output "alb_arn" {
  description = "ARN of alb"
  value       = try(aws_lb.this[0].arn, "")
}

output "alb_id" {
  description = "ID of alb"
  value       = try(aws_lb.this[0].arn, "")
}

output "alb_listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(aws_lb_listener.http[0].arn, "")
}

output "alb_listener_https_redirect_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(aws_lb_listener.front_end_https_http_redirect[0].arn, "")
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = try(aws_lb.this[0].dns_name, "")
}

/* ----------------------------------- DNS ---------------------------------- */
output "service_discovery_namespace" {
  description = "The ID of a namespace."
  value       = aws_service_discovery_private_dns_namespace.internal.id
}

/* ----------------------------------- CP ---------------------------------- */
output "capacity_provider_name" {
  description = "Name of capacity provider."
  value       = try(aws_ecs_capacity_provider.this[0].name, "")
}
