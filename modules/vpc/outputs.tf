output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "subnet_publica_id" {
  description = "ID da subnet publica"
  value       = aws_subnet.publica.id
}

output "subnet_privada_id" {
  description = "ID da subnet privada"
  value       = aws_subnet.privada.id
}
