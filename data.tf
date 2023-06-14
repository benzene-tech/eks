locals {
  required_subnets = toset(flatten([[for node_group in var.node_groups : node_group.subnet_type], ["private"]]))
}

data "aws_subnets" "this" {
  for_each = local.required_subnets

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
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
      error_message = "Required at least two ${each.value} subnets in ${var.vpc_id} vpc"
    }
  }
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
