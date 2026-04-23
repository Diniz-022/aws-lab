data "archive_file" "placas_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda_src/placas_monitor"
  output_path = "${path.root}/lambda_src/placas_monitor.zip"
}

resource "aws_iam_role" "lambda_placas" {
  name = "lambda-placas-monitor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_placas_policy" {
  name = "lambda-placas-policy"
  role = aws_iam_role.lambda_placas.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.placas_alertas.arn
      }
    ]
  })
}

resource "aws_sns_topic" "placas_alertas" {
  name = "placas-monitor-alertas"
}

resource "aws_sns_topic_subscription" "email_marcelo" {
  topic_arn = aws_sns_topic.placas_alertas.arn
  protocol  = "email"
  endpoint  = var.email_marcelo
}

resource "aws_sns_topic_subscription" "email_pedro" {
  topic_arn = aws_sns_topic.placas_alertas.arn
  protocol  = "email"
  endpoint  = var.email_pedro
}

resource "aws_lambda_function" "placas_monitor" {
  function_name    = "placas-monitor"
  role             = aws_iam_role.lambda_placas.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.placas_zip.output_path
  source_code_hash = data.archive_file.placas_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      API_TOKEN     = var.api_token
      SNS_TOPIC_ARN = aws_sns_topic.placas_alertas.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "placas_schedule" {
  name                = "placas-monitor-diario"
  description         = "Monitora saldo API Placas diariamente às 09h Brasília"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "placas_lambda" {
  rule      = aws_cloudwatch_event_rule.placas_schedule.name
  target_id = "PlacasMonitorLambda"
  arn       = aws_lambda_function.placas_monitor.arn
}

resource "aws_lambda_permission" "eventbridge_placas" {
  statement_id  = "AllowEventBridgeInvokePlacas"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.placas_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.placas_schedule.arn
}
