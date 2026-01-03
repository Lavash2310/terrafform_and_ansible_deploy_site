resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_main
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_sb" {
  for_each = { for idx, cidr in var.public_subnet_cidr : idx => cidr }
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = var.availability_zone[each.key]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${tonumber(each.key + 1)}"
  }
}

resource "aws_subnet" "private_sb" {
  for_each = { for idx, cidr in var.private_subnet_cidr : idx => cidr }
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value
  availability_zone = var.availability_zone[each.key]
  tags = {
    Name = "private-subnet-${tonumber(each.key + 1)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = aws_subnet.public_sb
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}