# EKS

Terraform module to create a EKS cluster instance.

## Usage

```terraform
module "eks" {
  source = "github.com/benzene-tech/ec2?ref=v1.0"

  name_prefix               = "example"
  vpc_id                    = "vpc-12345"
  node_group_scaling_config = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}
```
