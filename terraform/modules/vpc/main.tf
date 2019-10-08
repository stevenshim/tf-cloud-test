resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.vpc_name,
    Managed_by = "terraform"
  }
}

resource "aws_subnet" "vpc_public_subnets" {
  count = length(var.vpc_public_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = lookup(var.vpc_public_subnets[count.index], "cidr")
  availability_zone = lookup(var.vpc_public_subnets[count.index], "az")

  tags = {
    Name = "${var.vpc_name}-${lookup(var.vpc_public_subnets[count.index], "name")}"
    Managed_by = "terraform"
  }
}

resource "aws_subnet" "vpc_private_subnets" {
  count = length(var.vpc_private_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = lookup(var.vpc_private_subnets[count.index], "cidr")
  availability_zone = lookup(var.vpc_private_subnets[count.index], "az")

  tags = {
    Name = "${var.vpc_name}-${lookup(var.vpc_private_subnets[count.index], "name")}"
    Managed_by = "terraform"
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  count = 1
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
    Managed_by = "terraform"
  }
}

resource "aws_route_table" "vpc_public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw[0].id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
    Managed_by = "terraform"
  }
}

resource "aws_route_table" "vpc_private_rt" {
  vpc_id = aws_vpc.vpc.id

//  route {
//    cidr_block = "0.0.0.0/0"
//    nat_gateway_id = aws_nat_gateway.vpc_ngw.id
//  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
    Managed_by = "terraform"
  }
}

resource "aws_route_table_association" "vpc_public_rtable_association" {
  count = length(var.vpc_public_subnets)

  subnet_id = aws_subnet.vpc_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.vpc_public_rt.id
}

resource "aws_route_table_association" "vpc_private_rtable_association" {
  count = length(var.vpc_private_subnets)

  subnet_id = aws_subnet.vpc_private_subnets.*.id[count.index]
  route_table_id = aws_route_table.vpc_private_rt.id
}