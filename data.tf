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
}

data "aws_iam_role" "cluster" {
  name = var.cluster_role
}

data "aws_iam_role" "node_group" {
  count = length(var.node_groups) != 0 ? 1 : 0

  name = var.node_group_role

  lifecycle {
    precondition {
      condition     = var.node_group_role != null
      error_message = "'node_group_role' variable is required to create Node groups"
    }
  }
}

data "aws_iam_role" "fargate_profile" {
  count = length(var.fargate_profiles) != 0 ? 1 : 0

  name = var.fargate_profile_pod_execution_role

  lifecycle {
    precondition {
      condition     = var.fargate_profile_pod_execution_role != null
      error_message = "'fargate_profile_pod_execution_role' variable is required to create Fargate profiles"
    }
  }
}

data "aws_iam_role" "access_entries" {
  for_each = var.access_entries

  name = each.key
}
