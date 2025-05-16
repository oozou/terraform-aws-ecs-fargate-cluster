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
  value       = try(module.application_alb[0].alb_arn, "")
}

output "alb_id" {
  description = "ID of alb"
  value       = try(module.application_alb[0].alb_id, "")
}

output "alb_listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(module.application_alb[0].alb_listener_http_arn, "")
}

output "alb_listener_https_redirect_arn" {
  description = "ARN of the listener (matches id)."
  value       = try(module.application_alb[0].alb_listener_https_redirect_arn, "")
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = try(module.application_alb[0].alb_dns_name, "")
}

/* ----------------------------------- DNS ---------------------------------- */
output "service_discovery_namespace" {
  description = "The ID of a namespace."
  value       = try(module.application_alb[0].service_discovery_namespace, "")
}

/* ----------------------------------- CP ---------------------------------- */
output "capacity_provider_name" {
  description = "Name of capacity provider."
  value       = try(aws_ecs_capacity_provider.this[0].name, "")
}
