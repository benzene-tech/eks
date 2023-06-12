locals {
  aws_auth_config_map_data = {
    mapRoles = yamlencode(flatten(concat(
      [
        {
          rolearn  = one(data.aws_iam_role.node_group[*].arn)
          username = "system:node:{{EC2PrivateDNSName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes"
          ]
        },
        {
          rolearn  = one(data.aws_iam_role.fargate_profile[*].arn)
          username = "system:node:{{SessionName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes",
            "system:node-proxier"
          ]
        }
      ],
      var.aws_auth_roles
    )))
  }
}

resource "kubernetes_config_map" "aws_auth" {
  count = var.create_aws_auth_config_map ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_config_map_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = var.update_aws_auth_config_map ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data  = local.aws_auth_config_map_data
  force = true

  depends_on = [kubernetes_config_map.aws_auth]
}
