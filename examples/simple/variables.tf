variable "generics_info" {
  description = "Generic infomation"
  type = object({
    region      = string
    prefix      = string
    environment = string
    name        = string
    custom_tags = map(any)
  })
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy"
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "alb_certificate_arn" {
  type        = string
  description = "ARN of ssl in the ACM"
}

variable "allow_access_from_principals" {
  description = "A list of Account Numbers, ARNs, and Service Principals who needs to access the cluster"
  type        = list(string)
  default     = []
}