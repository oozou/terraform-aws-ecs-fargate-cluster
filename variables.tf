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

variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(any)
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                 ECS Cluster                                */
/* -------------------------------------------------------------------------- */
variable "is_enable_container_insights" {
  description = "Whether to be used to enable CloudWatch Container Insights for a cluster."
  type        = bool
  default     = true
}

/* -------------------------------------------------------------------------- */
/*                               Security Group                               */
/* -------------------------------------------------------------------------- */
variable "additional_security_group_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
variable "vpc_id" {
  description = "VPC to deploy the cluster in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for AWS Application Load Balancer deployment"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnets for container deployment"
  type        = list(string)
  default     = []
}

/* -------------------------------------------------------------------------- */
/*                               Security Group                               */
/* -------------------------------------------------------------------------- */
/* -------------------------------- ECS Tasks ------------------------------- */
variable "is_create_ecs_task_security_group" {
  description = "Whether to create ECS tasks security group or not"
  type        = bool
  default     = true
}
variable "ecs_task_security_group_id" {
  type        = string
  description = "(Require) when is_create_alb_security_group is set to `false`"
  default     = ""
}

/* ----------------------------------- ALB ---------------------------------- */
variable "is_create_alb_security_group" {
  description = "Whether to create ALB security group or not"
  type        = bool
  default     = true
}
variable "alb_aws_security_group_id" {
  type        = string
  description = "(Require) when is_create_alb_security_group is set to `false`"
  default     = ""
}

/* -------------------------------------------------------------------------- */
/*                                     ALB                                    */
/* -------------------------------------------------------------------------- */
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

variable "is_ignore_unsecured_connection" {
  description = "Whether to by pass the HTTPs endpoints required or not"
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "The port to listen on the ALB for public services (80/443, default 443)"
  type        = number
  default     = 443
}

variable "alb_certificate_arn" {
  description = "Certitificate ARN to link with ALB"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}
/* -------------------------------------------------------------------------- */
/*                                     DNS                                    */
/* -------------------------------------------------------------------------- */
variable "is_create_alb_dns_record" {
  description = "Whether to create ALB dns record or not"
  type        = bool
  default     = true
}

variable "route53_hosted_zone_name" {
  description = "The domain name in Route53 to fetch the hosted zone, i.e. example.com, mango-dev.blue.cloud"
  type        = string
  default     = ""
}

variable "fully_qualified_domain_name" {
  description = "The domain name for the ACM cert for attaching to the ALB i.e. *.example.com, www.amazing.com"
  type        = string
  default     = ""
}
/* -------------------------------------------------------------------------- */
/*                                  IAM Role                                  */
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

/* -------------------------------------------------------------------------- */
/*                                 Capacity Provider                          */
/* -------------------------------------------------------------------------- */
# variable "capacity_provider_auto_scaling_group_arn" {
#   description = "Auto scaling group arn for capacity provider EC2"
#   type        = string
#   default     = null
# }

variable "capacity_provider_asg_config" {
  description = "Auto scaling group arn for capacity provider EC2"
  type        = map(any)
  default     = null
}