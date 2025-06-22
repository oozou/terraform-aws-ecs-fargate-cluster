/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
module "vpc" {
  source       = "oozou/vpc/aws"
  version      = "1.2.5"
  prefix       = var.generic_info.prefix
  environment  = var.generic_info.environment
  account_mode = "spoke"

  cidr              = var.networking_info.vpc_cidr
  public_subnets    = var.networking_info.public_subnets
  private_subnets   = var.networking_info.private_subnets
  availability_zone = var.networking_info.availability_zones

  is_create_nat_gateway             = true
  is_enable_single_nat_gateway      = true
  is_enable_dns_hostnames           = true
  is_enable_dns_support             = true
  is_create_flow_log                = false
  is_enable_flow_log_s3_integration = false

  tags = var.generic_info.custom_tags
}

/* -------------------------------------------------------------------------- */
/*                                     ACM                                    */
/* -------------------------------------------------------------------------- */
module "acm" {
  source  = "oozou/acm/aws"
  version = "1.0.4"

  acms_domain_name         = var.acms_domain_name
  route53_zone_name        = var.route53_hosted_zone_name
  is_automatic_verify_acms = true
}

/* -------------------------------------------------------------------------- */
/*                               Fargate Cluster                              */
/* -------------------------------------------------------------------------- */
module "fargate_cluster" {
  source = "../.."

  # Generics
  prefix      = var.generic_info.prefix
  environment = var.generic_info.environment
  name        = var.generic_info.name

  # IAM Role
  ## If is_create_role is false, all of folowing argument is ignored
  is_create_role                 = var.is_create_role # Default is `true`
  allow_access_from_principals   = var.allow_access_from_principals
  additional_managed_policy_arns = var.additional_managed_policy_arns # Default is `[]`

  # VPC Information
  vpc_id = module.vpc.vpc_id

  # Security Group
  additional_security_group_ingress_rules = merge(
    {
      # allow_vpn_ec2_access_ecs_service_sg = {
      #   source_security_group_id = module.vpn.security_group_id
      #   protocol                 = "all",
      #   port                     = -1
      # }
    },
    var.additional_security_group_ingress_rules
  )

  # ALB
  is_create_alb               = var.is_create_alb              # Default is `true`
  is_public_alb               = var.is_public_alb              # Default is `false`
  enable_deletion_protection  = var.enable_deletion_protection # Default is `false`, open this on production
  alb_listener_port           = var.alb_listener_port
  alb_certificate_arn         = module.acm.certificate_arns["cms"]
  public_subnet_ids           = module.vpc.public_subnet_ids
  is_enable_access_log        = var.is_enable_alb_access_log
  alb_access_logs_bucket_name = var.alb_access_logs_bucket_name

  # ALB's DNS Record
  is_create_alb_dns_record    = var.is_create_alb_dns_record        # Default is `true`
  route53_hosted_zone_name    = var.route53_hosted_zone_name        # The zone that alb record will be created
  fully_qualified_domain_name = var.alb_fully_qualified_domain_name # ALB's record name

  tags = local.tags
}
