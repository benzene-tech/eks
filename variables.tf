variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

# VPC
variable "vpc_id" {
  description = "VPC ID. If VPC ID is not provided default VPC will be used"
  type        = string
  default     = null
}

# EKS cluster
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = 1.28
  nullable    = false
}

variable "enable_public_access_endpoint" {
  description = "Determine whether to enable or disable public access endpoint"
  type        = bool
  default     = true
  nullable    = false
}

variable "public_access_cidrs" {
  description = "List of CIDRs that can access EKS cluster's public endpoint"
  type        = list(string)
  default     = null
}

variable "cluster_subnet" {
  description = "Subnet type where the EKS cluster will be created"
  type        = string
  default     = "private"
  nullable    = false

  validation {
    condition     = contains(["public", "private"], var.cluster_subnet)
    error_message = "Subnet type should be either 'public' or 'private'"
  }
}

variable "cluster_iam_role_name" {
  description = "IAM role name for EKS cluster"
  type        = string
  nullable    = false
}

# Node Group
variable "node_groups" {
  description = "Node groups to be created"
  type = map(object(
    {
      subnet_type    = optional(string, "private")
      instance_types = optional(list(string), null)
      labels         = optional(map(string), null)
      scaling = object({
        desired_size = number
        min_size     = number
        max_size     = number
      })
      update = optional(object({
        max_unavailable            = optional(number, null)
        max_unavailable_percentage = optional(number, null)
      }), {})
    }
  ))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for node_group in var.node_groups : contains(["public", "private"], node_group.subnet_type)])
    error_message = "Subnet type should be either 'public' or 'private'"
  }

  validation {
    condition     = alltrue([for node_group in var.node_groups : (sum([for config in node_group.update : (config != null ? 1 : 0)]) <= 1)])
    error_message = "Either 'max_unavailable' or 'max_unavailable_percentage' should be set. Both are mutually exclusive"
  }
}

variable "node_group_iam_role_name" {
  description = "IAM role name to be used by node groups"
  type        = string
  default     = null
}

# Fargate
variable "fargate_profiles" {
  description = "Fargate profiles to be created"
  type = map(object(
    {
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

variable "fargate_profile_iam_role_name" {
  description = "IAM role name to be used by fargate profiles"
  type        = string
  default     = null
}

# AWS auth
variable "create_aws_auth_config_map" {
  description = "Determines whether to create the aws-auth configmap"
  type        = bool
  default     = false
  nullable    = false
}

variable "update_aws_auth_config_map" {
  description = "Determines whether to update the aws-auth configmap"
  type        = bool
  default     = false
  nullable    = false
}

variable "aws_auth_roles" {
  description = "AWS auth roles"
  type = list(object({
    username = string
    rolearn  = string
    groups   = list(string)
  }))
  default  = []
  nullable = false
}

variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default     = null
}
