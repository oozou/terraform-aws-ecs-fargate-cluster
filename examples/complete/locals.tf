locals {
  tags = merge(
    {
      "Environment" = var.generic_info.environment,
      "Terraform"   = "true"
    },
    var.generic_info.custom_tags
  )
}
