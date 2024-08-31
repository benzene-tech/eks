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

data "aws_iam_role" "this" {
  for_each = var.access_entries

  name = each.key
}
