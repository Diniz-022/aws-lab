# ===========================
# BUDGET - Controle de Custos
# Alerta quando o gasto mensal
# atingir 80% e 100% do limite
# ===========================
resource "aws_budgets_budget" "alerta_custo" {
  name         = "${var.project_name}-budget"
  budget_type  = "COST"
  limit_amount = "20"
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

# ===========================
# VPC - Rede
# Rede isolada na AWS com
# subnets publica e privada
# ===========================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-subnet-publica"
    Project = var.project_name
  }
}

resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project_name}-subnet-privada"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt-publica"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

# ===========================
# EC2 - Servidor
# Instancia de lab para
# testes e aprendizado
# ===========================
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "Security Group para EC2 do lab"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg-ec2"
    Project = var.project_name
  }
}

resource "aws_instance" "lab" {
  ami                    = "ami-0ea87431b78a82070"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0efbe6ee60a328e61"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = "aws-lab-key"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}

# ===========================
# S3 - Armazenamento
# Bucket com versionamento e
# bloqueio de acesso publico
# ===========================
resource "aws_s3_bucket" "lab" {
  bucket = "aws-lab-bucket-${var.project_name}-diniz"

  tags = {
    Name    = "${var.project_name}-bucket"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "lab" {
  bucket = aws_s3_bucket.lab.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "lab" {
  bucket = aws_s3_bucket.lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_metric_alarm" "s3_tamanho" {
  alarm_name          = "${var.project_name}-s3-tamanho"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 4294967296
  alarm_description   = "Alerta quando o bucket passar de 4GB"

  dimensions = {
    BucketName  = aws_s3_bucket.lab.id
    StorageType = "StandardStorage"
  }

  alarm_actions = []

  tags = {
    Name    = "${var.project_name}-s3-alarm"
    Project = var.project_name
  }
}

# ===========================
# IAM - Permissoes
# Roles e policies para EC2
# acessar o S3 com seguranca
# ===========================
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-s3-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.lab.arn,
          "${aws_s3_bucket.lab.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}

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
  source_file = "${path.module}/lambda/relatorio_custos.py"
  output_path = "${path.module}/lambda/relatorio_custos.zip"
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

# ===========================
# API GATEWAY - Endpoint HTTP
# Expoe a Lambda via URL HTTP
# para chamadas sob demanda
# ===========================
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  tags = {
    Name    = "${var.project_name}-api"
    Project = var.project_name
  }
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "prod"
  auto_deploy = true

  tags = {
    Name    = "${var.project_name}-api-stage"
    Project = var.project_name
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.relatorio_custos.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /relatorio"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.relatorio_custos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}