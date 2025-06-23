/* ------------------------------- ECS Cluster ------------------------------ */
output "ecs_cluster_arn" {
  description = "ARN that identifies the cluster."
  value       = module.fargate_cluster.ecs_cluster_arn
}

output "ecs_cluster_id" {
  description = "ID that identifies the cluster."
  value       = module.fargate_cluster.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the cluster"
  value       = module.fargate_cluster.ecs_cluster_name
}

/* ----------------------------- Security Group ----------------------------- */
output "ecs_task_security_group_id" {
  description = "ID of the security group rule."
  value       = module.fargate_cluster.ecs_task_security_group_id
}

/* -------------------------------- IAM Role -------------------------------- */
output "ecs_access_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = module.fargate_cluster.ecs_access_role_arn
}

/* ----------------------------------- ALB ---------------------------------- */
output "alb_arn" {
  description = "ARN of alb"
  value       = module.fargate_cluster.alb_arn
}

output "alb_id" {
  description = "ID of alb"
  value       = module.fargate_cluster.alb_id
}

output "alb_listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value       = module.fargate_cluster.alb_listener_http_arn
}

output "alb_listener_https_redirect_arn" {
  description = "ARN of the listener (matches id)."
  value       = module.fargate_cluster.alb_listener_https_redirect_arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.fargate_cluster.alb_dns_name
}

/* ----------------------------------- DNS ---------------------------------- */
output "service_discovery_namespace" {
  description = "The ID of a namespace."
  value       = module.fargate_cluster.service_discovery_namespace
}

/* ----------------------------------- ACM ---------------------------------- */
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.acm.certificate_arns["cms"]
}

/* ----------------------------------- VPC ---------------------------------- */
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
