data "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster_iam_role_name
}

resource "aws_eks_cluster" "this" {
  name     = var.name_prefix
  role_arn = data.aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = data.aws_subnets.this["private"].ids
    public_access_cidrs     = var.enable_public_access_endpoint ? var.public_access_cidrs : null
    endpoint_public_access  = var.enable_public_access_endpoint
    endpoint_private_access = true
  }
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks_cluster.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks_cluster.url

  tags = {
    cluster-name = aws_eks_cluster.this.id
  }
}
