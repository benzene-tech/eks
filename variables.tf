variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

variable "enable_public_access_endpoint" {
  description = "Flag to enable or disable public access endpoint"
  type        = bool
  default     = true
  nullable    = false
}

variable "public_access_cidrs" {
  description = "List of CIDRs that can access EKS cluster's public endpoint"
  type        = list(string)
  default     = null
}

# VPC
variable "vpc_id" {
  description = "VPC ID"
  type        = string
  nullable    = false
}

# Node Group
variable "node_group_scaling_config" {
  description = "Scaling config for node group"
  type = object(
    {
      desired_size = number
      max_size     = number
      min_size     = number
    }
  )
  default = null
}

# Fargate
variable "fargate_profiles" {
  description = "Fargate profiles to created"
  type = map(object(
    {
      name = string
      selectors = set(object(
        {
          namespace = string
          labels    = optional(map(string))
        }
      ))
    }
  ))
  default  = {}
  nullable = false
}
