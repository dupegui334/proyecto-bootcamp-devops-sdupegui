# Data
data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "main",
    Owner = var.owner
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name  = "public-${data.aws_availability_zones.available.names[count.index]}",
    Owner = lower(var.owner)
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name  = "private-${data.aws_availability_zones.available.names[count.index]}",
    Owner = lower(var.owner)
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "Internet Gateway Main",
    Owner = lower(var.owner)
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name  = "NAT Gateway Main",
    Owner = lower(var.owner)
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name  = "public",
    Owner = lower(var.owner)
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name  = "private",
    Owner = lower(var.owner)
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr_block)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr_block)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name  = "Main DB subnet group"
    Owner = lower(var.owner)
  }
}