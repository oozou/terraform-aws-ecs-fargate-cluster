generic_info = {
  prefix      = "oozou"
  environment = "devops"
  name        = "demo"
  region      = "ap-southeast-1"
  custom_tags = {
    "Remark" = "terraform-aws-ecs-service"
  }
}

route53_hosted_zone_name = "devops.team.oozou.com"

/* -------------------------------------------------------------------------- */
/*                                 Networking                                 */
/* -------------------------------------------------------------------------- */
networking_info = {
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.0.0/24", "10.0.4.0/24"]
  private_subnets    = ["10.0.8.0/23", "10.0.16.0/23"]
  availability_zones = ["ap-southeast-1b", "ap-southeast-1c"]
}

/* -------------------------------------------------------------------------- */
/*                                     ACM                                    */
/* -------------------------------------------------------------------------- */
acms_domain_name = {
  cms = {
    domain_name = "terraform-test.devops.team.oozou.com"
  }
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
is_create_role                          = false
additional_security_group_ingress_rules = {}
is_public_alb                           = true
enable_deletion_protection              = false # Use cloudfront forwarding traffic
is_enable_alb_access_log                = false
is_create_alb_dns_record                = true
alb_fully_qualified_domain_name        = "terraform-test.devops.team.oozou.com"