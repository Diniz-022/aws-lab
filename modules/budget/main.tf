# ===========================
# BUDGET - Controle de Custos
# Alerta quando o gasto mensal
# atingir 80% e 100% do limite
# ===========================
resource "aws_budgets_budget" "alerta_custo" {
  name         = "${var.project_name}-budget"
  budget_type  = "COST"
  limit_amount = var.limit_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email_alerta]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email_alerta]
  }
}
