variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

# VPC
variable "vpc_id" {
  description = "VPC ID"
  type        = string
  nullable    = false
}

# EKS cluster
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = 1.25
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

variable "eks_cluster_iam_role_name" {
  description = "IAM role name for EKS cluster"
  type        = string
  nullable    = false
}

# Node Group
variable "node_groups" {
  description = "Node groups to be created"
  type = map(object(
    {
      subnet_type    = string
      instance_types = optional(list(string), null)
      scaling = object({
        desired_size = number
        max_size     = number
        min_size     = number
      })
    }
  ))
  default = {}

  validation {
    condition     = alltrue([for node_group in var.node_groups : contains(["public", "private"], node_group.subnet_type)])
    error_message = "Subnet type should be either 'public' or 'private'"
  }
}

variable "node_group_iam_role_name" {
  description = "IAM role name to be used by node groups"
  type        = string
  default     = ""
  nullable    = false
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
  default     = ""
  nullable    = false
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
