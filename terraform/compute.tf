data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_project_key"
  public_key = file(pathexpand("${var.ssh_key_path}.pub"))
}

resource "aws_instance" "web_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.public_sb)[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "web-instance"
    OS  = "ubuntu"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = <<EOT
[servers]
${aws_instance.web_instance.public_ip} ansible_user=${
  aws_instance.web_instance.tags.OS == "ubuntu" ? "ubuntu" : 
  aws_instance.web_instance.tags.OS == "debian" ? "admin" : "ec2-user"
} ansible_ssh_private_key_file=${var.ssh_key_path}
EOT

  depends_on = [aws_instance.web_instance]
}