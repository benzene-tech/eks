locals {
  required_subnets = toset(flatten([[var.cluster_subnet], [for node_group in var.node_groups : node_group.subnet_type], length(var.fargate_profiles) != 0 ? ["private"] : []]))
}

data "aws_vpc" "this" {
  id      = var.vpc_id
  default = var.vpc_id == null ? true : null
}

data "aws_subnets" "this" {
  for_each = local.required_subnets

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = [each.value == "public" ? "true" : "false"]
  }

  lifecycle {
    postcondition {
      condition     = length(self.ids) > 1
      error_message = "Required at least two ${each.value} subnets in ${data.aws_vpc.this.id} vpc"
    }
  }
}
