variable "name" {
  description = "Name to use for resources"
  type        = string
  nullable    = false
}

# VPC
variable "vpc_cidr_block" {
  description = "VPC CIDR"
  type        = string
  nullable    = false
}

variable "public_subnets_count" {
  description = "Number of public subnets to create. If load balancer is enabled, public_subnet_count value should be minimum of 2"
  default     = 2
  type        = number
  nullable    = false

  validation {
    condition     = var.public_subnets_count % 1 == 0 && var.public_subnets_count > 0
    error_message = "Number of public subnets should be a non zero whole number"
  }
}
