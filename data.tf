data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "this" {
  for_each = toset(["public", "private"])

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*_${each.value}"
  }
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
