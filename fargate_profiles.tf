resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = one(data.aws_iam_role.fargate_profile[*].arn)
  subnet_ids             = data.aws_subnets.this["private"].ids

  dynamic "selector" {
    for_each = each.value["selectors"]

    content {
      namespace = selector.value["namespace"]
      labels    = selector.value["labels"]
    }
  }

  tags = var.tags
}
