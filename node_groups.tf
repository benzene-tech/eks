data "aws_iam_role" "node_group" {
  count = length(var.node_groups) != 0 ? 1 : 0

  name = var.node_group_iam_role_name
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  version         = var.kubernetes_version
  node_role_arn   = one(data.aws_iam_role.node_group[*].arn)
  subnet_ids      = data.aws_subnets.this[each.value.subnet_type].ids
  instance_types  = each.value.instance_types

  scaling_config {
    desired_size = each.value.scaling.desired_size
    max_size     = each.value.scaling.max_size
    min_size     = each.value.scaling.min_size
  }
}
