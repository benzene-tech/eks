resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  version         = aws_eks_cluster.this.version
  ami_type        = each.value.ami_type
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  labels          = each.value.labels
  subnet_ids      = data.aws_subnets.this[each.value.subnet_type].ids
  node_role_arn   = one(data.aws_iam_role.node_group[*].arn)

  dynamic "taint" {
    for_each = each.value.taints

    content {
      key    = taint.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  scaling_config {
    desired_size = each.value.scaling.desired_size
    max_size     = each.value.scaling.max_size
    min_size     = each.value.scaling.min_size
  }

  update_config {
    max_unavailable            = each.value.update.max_unavailable_percentage == null ? coalesce(each.value.update.max_unavailable, 1) : null
    max_unavailable_percentage = each.value.update.max_unavailable_percentage
  }

  tags = var.tags
}
