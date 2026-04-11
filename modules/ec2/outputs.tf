output "ec2_id" {
  description = "ID da EC2"
  value       = aws_instance.lab.id
}

output "ec2_ip_publico" {
  description = "IP publico da EC2"
  value       = aws_instance.lab.public_ip
}
