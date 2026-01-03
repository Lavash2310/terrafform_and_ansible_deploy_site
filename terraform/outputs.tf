output "web_public_ip" {
  description = "The public IP address of the web instance"
  value       = aws_instance.web_instance.public_ip
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = values(aws_subnet.private_sb)[*].id
}

output "ssh_command" {
  description = "The SSH command to access the web instance"
  value       = "ssh -i ${var.ssh_key_path} ubuntu@${aws_instance.web_instance.public_ip}"
}

output "ssh_instructions" {
  description = "Instructions to SSH into the web instance"
  value       = <<EOT

  Public IP Address: ${aws_instance.web_instance.public_ip}
  Key Path: ${var.ssh_key_path}

  To connect to the web instance, use the following command:

  # Ubunutu server users should use this command
  ssh -i ${var.ssh_key_path} ubuntu@${aws_instance.web_instance.public_ip}

  # Amazon Linux server users should use this command
  ssh -i ${var.ssh_key_path} ec2-user@${aws_instance.web_instance.public_ip}

  # Debeian server users should use this command
  ssh -i ${var.ssh_key_path} admin@${aws_instance.web_instance.public_ip}
EOT
}