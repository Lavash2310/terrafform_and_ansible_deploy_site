terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_main
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_sb" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_sb" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "private-subnet ${count.index + 1}"
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
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_sb[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH, HTTP, and custom port"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_project_key"
  public_key = file("~/.ssh/aws_project_key.pub")
}

resource "aws_instance" "web_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_sb[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "web-instance"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[servers]" > ../ansible/inventory.ini
      echo "aws_server ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_key_path}" >> ../ansible/inventory.ini
    EOT
  }
}