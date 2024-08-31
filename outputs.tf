output "name" {
  description = "Cluster name"
  value       = aws_eks_cluster.this.id

  depends_on = [
    aws_eks_access_policy_association.admin,
    aws_eks_access_policy_association.admin_view,
    aws_eks_access_policy_association.cluster_admin,
    aws_eks_access_policy_association.edit,
    aws_eks_access_policy_association.view
  ]
}

output "addons" {
  description = "Addons installed"
  value       = { for addon in aws_eks_addon.this : addon.addon_name => addon.addon_version }
}
