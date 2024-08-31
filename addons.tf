resource "aws_eks_addon" "this" {
  for_each = local.addons

  cluster_name  = aws_eks_cluster.this.id
  addon_name    = each.key
  addon_version = lookup(each.value, "version", null)
}
