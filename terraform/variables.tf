variable "aws_region" {
  description = "The AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "The type of instance to use"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
  default     = "ami-0e6a50b0059fd2cc3"
}

variable "vpc_main" {
  description = "The main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}

variable "ssh_key_path" {
  description = "Шлях до твого приватного ключа на MacBook"
  type        = string
  default     = "~/.ssh/aws_project_key"
}