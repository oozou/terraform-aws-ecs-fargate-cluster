# Setup DNS Discovery
resource "aws_service_discovery_private_dns_namespace" "internal" {
  # This name does not follow convention because it is used as part of the domain name
  name        = "${local.cluster_name}.internal"
  description = "Service Discovery for internal communcation for ${local.cluster_name} ECS cluster"
  vpc         = var.vpc_id
}

# For both internal and external use public hosted zone
data "aws_route53_zone" "route53_zone" {
  name         = var.route53_hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "application" {
  count   = var.enable_friendly_dns_for_alb_endpoint == true ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.id
  name    = var.fully_qualified_domain_name
  type    = "A"

  alias {
    name                   = var.public_alb == true ? lower(aws_lb.main_public[0].dns_name) : lower(aws_lb.main_private[0].dns_name)
    zone_id                = var.public_alb == true ? aws_lb.main_public[0].zone_id : aws_lb.main_private[0].zone_id
    evaluate_target_health = true
  }
}
