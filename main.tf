# EKS
resource "aws_eks_cluster" "this" {
  name     = var.name_prefix
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = data.aws_subnets.private.ids
    public_access_cidrs     = var.enable_public_access_endpoint ? var.public_access_cidrs : null
    endpoint_public_access  = var.enable_public_access_endpoint
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.name_prefix}_eks_cluster"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "eks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  for_each = toset(["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController"])

  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks_cluster.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks_cluster.url

  tags = {
    cluster-name = aws_eks_cluster.this.id
  }
}

# Node group
resource "aws_eks_node_group" "this" {
  count = var.node_group_scaling_config != null ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.name_prefix
  version         = var.kubernetes_version
  node_role_arn   = aws_iam_role.node_group[0].arn
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = var.node_group_scaling_config["desired_size"]
    max_size     = var.node_group_scaling_config["max_size"]
    min_size     = var.node_group_scaling_config["min_size"]
  }

  depends_on = [aws_iam_role_policy_attachment.node_group]
}

resource "aws_iam_role" "node_group" {
  count = var.node_group_scaling_config != null ? 1 : 0

  name = "${var.name_prefix}_node-group"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_group" {
  for_each = var.node_group_scaling_config != null ? toset(["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly"]) : []

  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.node_group[0].name
}

# Fargate
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = each.value["name"]
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = data.aws_subnets.private.ids

  dynamic "selector" {
    for_each = each.value["selectors"]

    content {
      namespace = selector.value["namespace"]
      labels    = selector.value["labels"]
    }
  }

  depends_on = [aws_iam_role_policy_attachment.fargate[0]]
}

resource "aws_iam_role" "fargate" {
  count = var.fargate_profiles != {} ? 1 : 0

  name = "${var.name_prefix}_fargate"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "eks-fargate-pods.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "fargate" {
  count = var.fargate_profiles != {} ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}
