locals {
  policy_arn = sensitive("arn:aws:iam::aws:policy/AmazonEKSClusterPolicy")
  assume_role_policy = sensitive(jsonencode(
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
  ))
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.public : subnet.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_iam_role" "eks_cluster" {
  name               = "eks_cluster"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = local.policy_arn
}
