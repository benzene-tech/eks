output "name" {
  description = "Cluster name"
  value       = aws_eks_cluster.this.id
}

output "addons" {
  description = "Addons installed"
  value       = { for addon in aws_eks_addon.this : addon.addon_name => addon.addon_version }
}
