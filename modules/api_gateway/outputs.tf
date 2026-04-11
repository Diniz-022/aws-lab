output "api_url" {
  description = "URL da API Gateway"
  value       = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}/relatorio"
}
