data "aws_iam_role" "eks_cluster" {
  name = var.cluster_iam_role_name
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = data.aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = data.aws_subnets.this[var.cluster_subnet].ids
    public_access_cidrs     = var.enable_public_access_endpoint ? var.public_access_cidrs : null
    endpoint_public_access  = var.enable_public_access_endpoint
    endpoint_private_access = true
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = length(data.aws_subnets.this[var.cluster_subnet].ids) > 1
      error_message = "Required at least two subnets of same type to create EKS cluster"
    }
  }
}

check "cluster_subnet" {
  assert {
    condition     = var.cluster_subnet == "private"
    error_message = "AWS recommends to create EKS clusters in private subnets, if possible"
  }
}
