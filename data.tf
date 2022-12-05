data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*_private"
  }
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
