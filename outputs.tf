output "budget_id" {
  description = "ID do budget criado"
  value       = module.budget.budget_id
}

output "ec2_id" {
  description = "ID da EC2"
  value       = module.ec2.ec2_id
}

output "ec2_ip_publico" {
  description = "IP publico da EC2"
  value       = module.ec2.ec2_ip_publico
}

output "ec2_ssh" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i ~/.ssh/aws-lab-key.pem ec2-user@${module.ec2.ec2_ip_publico}"
}

output "s3_bucket_nome" {
  description = "Nome do bucket S3"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.s3.bucket_arn
}

output "lambda_nome" {
  description = "Nome da Lambda"
  value       = module.lambda.lambda_nome
}

output "lambda_arn" {
  description = "ARN da Lambda"
  value       = module.lambda.lambda_arn
}

output "api_url" {
  description = "URL da API Gateway"
  value       = module.api_gateway.api_url
}

output "budget_limit" {
  description = "Limite do budget"
  value       = "20 USD"
}