output "budget_id" {
  description = "ID do budget criado"
  value       = aws_budgets_budget.alerta_custo.id
}

output "budget_limit" {
  description = "Limite do budget"
  value       = "${aws_budgets_budget.alerta_custo.limit_amount} ${aws_budgets_budget.alerta_custo.limit_unit}"
}

output "ec2_id" {
  description = "ID da EC2 criada"
  value       = aws_instance.lab.id
}

output "ec2_ip_publico" {
  description = "IP público da EC2"
  value       = aws_instance.lab.public_ip
}

output "ec2_ssh" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i ~/.ssh/aws-lab-key.pem ec2-user@${aws_instance.lab.public_ip}"
}


output "s3_bucket_nome" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.lab.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.lab.arn
}

output "lambda_nome" {
  description = "Nome da Lambda de relatório de custos"
  value       = aws_lambda_function.relatorio_custos.function_name
}

output "lambda_arn" {
  description = "ARN da Lambda"
  value       = aws_lambda_function.relatorio_custos.arn
}