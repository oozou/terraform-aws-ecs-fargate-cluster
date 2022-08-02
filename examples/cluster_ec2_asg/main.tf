module "fargate_cluster" {

  source = "../.."

  # Generics
  prefix      = var.generics_info.prefix
  environment = var.generics_info.environment
  name        = var.generics_info.name

  # IAM Role
  ## If is_create_role is false, all of folowing argument is ignored
  is_create_role                 = true
  allow_access_from_principals   = var.allow_access_from_principals
  additional_managed_policy_arns = []

  # VPC Information
  vpc_id = var.vpc_id

  additional_security_group_ingress_rules = {}

  # ALB
  is_create_alb              = true
  is_public_alb              = true
  enable_deletion_protection = false
  alb_listener_port          = 443
  alb_certificate_arn        = var.alb_certificate_arn
  public_subnet_ids          = var.subnet_ids # If is_public_alb is true, public_subnet_ids is required

  capacity_provider_asg_config = {
    asg_arn                   = module.auto_scaling_group.autoscaling_group_arn
    target_capacity           = 100
    maximum_scaling_step_size = 1000
    minimum_scaling_step_size = 1
  }

  # ALB's DNS Record
  is_create_alb_dns_record = false

  tags = var.generics_info.custom_tags
}
