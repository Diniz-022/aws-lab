output "lambda_arn" {
  description = "ARN da Lambda"
  value       = aws_lambda_function.relatorio_custos.arn
}

output "lambda_nome" {
  description = "Nome da Lambda"
  value       = aws_lambda_function.relatorio_custos.function_name
}

output "lambda_invoke_arn" {
  description = "ARN de invocacao da Lambda"
  value       = aws_lambda_function.relatorio_custos.invoke_arn
}
