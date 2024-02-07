/* -------------------------------------------------------------------------- */
/*                                   Generic                                  */
/* -------------------------------------------------------------------------- */
variable "generic_info" {
  description = "Generic infomation"
  type = object({
    region      = string
    prefix      = string
    environment = string
    name        = string
    custom_tags = map(any)
  })
}

variable "route53_hosted_zone_name" {
  description = "The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud"
  type        = string
  default     = ""
}

/* -------------------------------------------------------------------------- */
/*                                 Networking                                 */
/* -------------------------------------------------------------------------- */
variable "networking_info" {
  description = "Networking information"
  type = object({
    vpc_cidr           = string
    availability_zones = list(string)
    public_subnets     = list(string)
    private_subnets    = list(string)
  })
}

/* -------------------------------------------------------------------------- */
/*                                     ACM                                    */
/* -------------------------------------------------------------------------- */
variable "acms_domain_name" {
  description = "acm"
  type        = any
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
variable "is_create_role" {
  description = "Whether to create ecs role or not"
  type        = bool
  default     = true
}

variable "allow_access_from_principals" {
  description = "A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster"
  type        = list(string)
  default     = []
}

variable "additional_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed_policy_arns = []) will cause Terraform to remove all managed policy attachments."
  type        = list(string)
  default     = []
}

variable "additional_security_group_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "is_create_alb" {
  description = "Whether to create alb or not"
  type        = bool
  default     = true
}

variable "is_public_alb" {
  description = "Flag for Internal/Public ALB. ALB is production env should be public"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "The port to listen on the ALB for public services (80/443, default 443)"
  type        = number
  default     = 443
}

variable "is_enable_alb_access_log" {
  description = "Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  type        = bool
  default     = false
}

variable "alb_access_logs_bucket_name" {
  description = "ALB access_logs S3 bucket name."
  type        = string
  default     = ""
}

variable "is_create_alb_dns_record" {
  description = "Whether to create ALB dns record or not"
  type        = bool
  default     = true
}

variable "alb_fully_qualified_domain_name" {
  description = "The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com"
  type        = string
  default     = ""
}
