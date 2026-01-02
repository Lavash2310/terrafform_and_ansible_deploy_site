output "web_public_ip" {
  description = "The public IP address of the web instance"
  value       = aws_instance.web_instance.public_ip
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private_sb[*].id
}

output "ssh_command" {
  description = "The SSH command to access the web instance"
  value       = "ssh -i ${var.ssh_key_path} ubuntu@${aws_instance.web_instance.public_ip}"
}