# VPC

resource "aws_vpc" "wp" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Public network

resource "aws_internet_gateway" "wp" {
  vpc_id = aws_vpc.wp.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.wp.id
  cidr_block              = "10.0.0.64/27"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.wp.id
  cidr_block              = "10.0.0.96/27"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private network

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.wp.id
  cidr_block        = "10.0.0.0/27"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.wp.id
  cidr_block        = "10.0.0.32/27"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wp.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wp.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# NAT Gateway

resource "aws_eip" "wp" {
  domain = "vpc"
}

resource "aws_nat_gateway" "wp" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.wp.id
}
