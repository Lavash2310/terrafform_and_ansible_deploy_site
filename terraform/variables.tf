variable "aws_region" {
  description = "The AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "The type of instance to use"
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "The instance type must be t2.micro, t3.small, or t3.medium."
  }
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
  default     = "/Users/delphin/.ssh/aws_project_key"
}