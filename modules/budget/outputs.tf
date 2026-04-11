output "budget_id" {
  description = "ID do budget criado"
  value       = aws_budgets_budget.alerta_custo.id
}
