/* -------------------------------------------------------------------------- */
/*                                   Generic                                  */
/* -------------------------------------------------------------------------- */

variable "name" {
  description = "Name of the ECS cluster to create"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */


variable "vpc_id" {
  description = "VPC to deploy the cluster in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for AWS Application Load Balancer deployment"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets for container deployment"
  type        = list(string)
}

variable "allow_access_from_principals" {
  description = "A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster"
  type        = list(string)
}

variable "alb_listener_port" {
  description = "The port to listen on the ALB for public services (80/443, default 443)"
  type        = number
  default     = 443
}

variable "custom_tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(any)
  default     = {}
}

variable "certificate_arn" {
  description = "Certitificate ARN to link with ALB"
  type        = string
}

variable "enable_friendly_dns_for_alb_endpoint" {
  description = "Disable DNS mapping with ALB when used with AWS CDN, to route traffic to CDN."
  type        = bool
  default     = true
}

variable "public_alb" {
  description = "Flag for Internal/Public ALB. ALB is production env should be public"
  type        = bool
  default     = false
}

variable "route53_hosted_zone_name" {
  description = "The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud"
  type        = string
}

variable "fully_qualified_domain_name" {
  description = "The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com"
  type        = string
}

# variable "alb_access_logs_bucket" {
#   description = "AWS ALB Access Logs Bucket"
#   type        = string
# }

# variable "account_alias" {
#   description = "Alias of the AWS account where this service is created. Eg. alpha/beta/prod. This would be used create s3 bucket path in the logging account"
#   type        = string
# }
