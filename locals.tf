locals {
  required_subnets = toset(flatten([[var.cluster_subnet], [for node_group in var.node_groups : node_group.subnet_type], length(var.fargate_profiles) != 0 ? ["private"] : []]))

  addons = {
    eks-pod-identity-agent = {}
  }
}
