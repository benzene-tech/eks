variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

# VPC
variable "vpc_cidr_block" {
  description = "VPC CIDR"
  type        = string
  nullable    = false
}
