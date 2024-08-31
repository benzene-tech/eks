variable "name" {
  description = "Name resources or add as tag"
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
  default     = null
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

variable "cluster_role" {
  description = "IAM role name for EKS cluster"
  type        = string
  nullable    = false
}

variable "access_entries" {
  description = "IAM access entries"
  type = map(object({
    groups = optional(list(string), null)
    policies = optional(map(object({
      scope      = string
      namespaces = optional(list(string), null)
    })), null)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([for entry in var.access_entries : (length(setintersection(toset([
      "AmazonEKSAdminPolicy",
      "AmazonEKSAdminViewPolicy",
      "AmazonEKSClusterAdminPolicy",
      "AmazonEKSEditPolicy",
      "AmazonEKSViewPolicy"
    ]), toset(keys(entry.policies)))) > 0)])
    error_message = "Policy should be one among 'AmazonEKSAdminPolicy', 'AmazonEKSAdminViewPolicy', 'AmazonEKSClusterAdminPolicy', 'AmazonEKSEditPolicy' or 'AmazonEKSViewPolicy'"
  }

  validation {
    condition = alltrue(flatten([for entry in var.access_entries : [
      for policy in entry.policies : contains(["cluster", "namespace"], policy.scope)
    ]]))
    error_message = "Access scope should be either 'cluster' or 'namespace'"
  }

  validation {
    condition = alltrue(flatten([for entry in var.access_entries : [
      for policy in entry.policies : (try(length(policy.namespaces), 0) == 0) if policy.scope == "cluster"
    ]]))
    error_message = "Namespaces not required if access scope is 'cluster'"
  }

  validation {
    condition = alltrue(flatten([for entry in var.access_entries : [
      for policy in entry.policies : (try(length(policy.namespaces), 0) > 0) if policy.scope == "namespace"
    ]]))
    error_message = "Namespaces cannot be empty if access scope is 'namespace'"
  }
}

# Node Group
variable "node_groups" {
  description = "Node groups to be created"
  type = map(object(
    {
      ami_type       = optional(string, null)
      instance_types = optional(list(string), null)
      capacity_type  = optional(string, "ON_DEMAND")
      labels         = optional(map(string), null)
      subnet_type    = optional(string, "private")
      taints = optional(map(object({
        value  = optional(string)
        effect = string
      })), {})
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
    condition     = alltrue([for node_group in var.node_groups : contains(["ON_DEMAND", "SPOT"], node_group.capacity_type)])
    error_message = "Capacity type should be either 'ON_DEMAND' or 'SPOT'"
  }

  validation {
    condition     = alltrue([for node_group in var.node_groups : (sum([for config in node_group.update : (config != null ? 1 : 0)]) <= 1)])
    error_message = "Either 'max_unavailable' or 'max_unavailable_percentage' should be set. Both are mutually exclusive"
  }
}

variable "node_group_role" {
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

variable "fargate_profile_pod_execution_role" {
  description = "IAM role name to be used by fargate profiles"
  type        = string
  default     = null
}


variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default     = null
}
