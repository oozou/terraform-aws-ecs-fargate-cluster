generic_info = {
  prefix      = "oozou"
  environment = "devops"
  name        = "demo"
  region      = "ap-southeast-1"
  custom_tags = {
    "Remark" = "terraform-aws-ecs-service"
  }
}

route53_hosted_zone_name = "<your_route53_zone>"

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
    domain_name = "<domain>"
    subject_alternative_names = [
      "<domain>",
      "<domain2>",
    ]
  }
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
is_create_role                          = true
allow_access_from_principals            = ["arn:aws:iam::<account_id>:root"]
additional_security_group_ingress_rules = {}
is_public_alb                           = true
enable_deletion_protection              = false # Use cloudfront forwarding traffic
is_enable_alb_access_log                = false
is_create_alb_dns_record                = false
