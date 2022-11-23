locals {
  subnet_bits              = ceil(log(var.public_subnets_count, 2))
  public_cidr_subnets      = [for net in range(var.public_subnets_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, net)]
  availability_zones_count = length(data.aws_availability_zones.available.names)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.name}_vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(local.public_cidr_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidr_subnets[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = count.index < local.availability_zones_count ? data.aws_availability_zones.available.names[count.index] : data.aws_availability_zones.available.names[count.index % local.availability_zones_count]

  tags = {
    Name = "${var.name}_public_subnet_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}_internet_gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}_public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
