data "aws_iam_role" "eks_cluster" {
  name = var.cluster_role
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

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
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

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.id
  principal_arn     = data.aws_iam_role.this[each.key].arn
  kubernetes_groups = each.value.groups
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = { for role, config in var.access_entries : role => {
    scope      = config.policies["AmazonEKSAdminPolicy"].scope
    namespaces = config.policies["AmazonEKSAdminPolicy"].namespaces
  } if contains(keys(config.policies), "AmazonEKSAdminPolicy") }

  cluster_name  = aws_eks_cluster.this.id
  principal_arn = data.aws_iam_role.this[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}

resource "aws_eks_access_policy_association" "admin_view" {
  for_each = { for role, config in var.access_entries : role => {
    scope      = config.policies["AmazonEKSAdminViewPolicy"].scope
    namespaces = config.policies["AmazonEKSAdminViewPolicy"].namespaces
  } if contains(keys(config.policies), "AmazonEKSAdminViewPolicy") }

  cluster_name  = aws_eks_cluster.this.id
  principal_arn = data.aws_iam_role.this[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = { for role, config in var.access_entries : role => {
    scope      = config.policies["AmazonEKSClusterAdminPolicy"].scope
    namespaces = config.policies["AmazonEKSClusterAdminPolicy"].namespaces
  } if contains(keys(config.policies), "AmazonEKSClusterAdminPolicy") }

  cluster_name  = aws_eks_cluster.this.id
  principal_arn = data.aws_iam_role.this[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}

resource "aws_eks_access_policy_association" "edit" {
  for_each = { for role, config in var.access_entries : role => {
    scope      = config.policies["AmazonEKSEditPolicy"].scope
    namespaces = config.policies["AmazonEKSEditPolicy"].namespaces
  } if contains(keys(config.policies), "AmazonEKSEditPolicy") }

  cluster_name  = aws_eks_cluster.this.id
  principal_arn = data.aws_iam_role.this[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}

resource "aws_eks_access_policy_association" "view" {
  for_each = { for role, config in var.access_entries : role => {
    scope      = config.policies["AmazonEKSViewPolicy"].scope
    namespaces = config.policies["AmazonEKSViewPolicy"].namespaces
  } if contains(keys(config.policies), "AmazonEKSViewPolicy") }

  cluster_name  = aws_eks_cluster.this.id
  principal_arn = data.aws_iam_role.this[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}
