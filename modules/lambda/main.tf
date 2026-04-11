# ===========================
# LAMBDA - Funcao Serverless
# Gera relatorio de custos AWS
# e envia por email toda segunda
# ===========================
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-lambda-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ses:SendEmail",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/relatorio_custos.py"
  output_path = "${path.module}/../../lambda/relatorio_custos.zip"
}

resource "aws_lambda_function" "relatorio_custos" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-relatorio-custos"
  role             = aws_iam_role.lambda_role.arn
  handler          = "relatorio_custos.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30

  tags = {
    Name    = "${var.project_name}-relatorio-custos"
    Project = var.project_name
  }
}

# ===========================
# EVENTBRIDGE - Agendamento
# Dispara a Lambda toda segunda
# as 09h horario de Brasilia
# ===========================
resource "aws_cloudwatch_event_rule" "toda_segunda" {
  name                = "${var.project_name}-toda-segunda-9h"
  description         = "Dispara toda segunda as 09h horario Brasilia"
  schedule_expression = "cron(0 12 ? * MON *)"

  tags = {
    Name    = "${var.project_name}-toda-segunda"
    Project = var.project_name
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.toda_segunda.name
  target_id = "RelatorioLambda"
  arn       = aws_lambda_function.relatorio_custos.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.relatorio_custos.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.toda_segunda.arn
}
