# ===========================
# BUDGET - Controle de Custos
# ===========================
module "budget" {
  source       = "./modules/budget"
  project_name = var.project_name
  limit_amount = "20"
  email_alerta = var.email_alerta
}

# ===========================
# VPC - Rede
# ===========================
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  region       = var.region
}

# ===========================
# S3 - Armazenamento
# ===========================
module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}

# ===========================
# EC2 - Servidor
# ===========================
module "ec2" {
  source        = "./modules/ec2"
  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.subnet_publica_id
  key_name      = "aws-lab-key"
  s3_bucket_arn = module.s3.bucket_arn
}

# ===========================
# LAMBDA - Funcao Serverless
# ===========================
module "lambda" {
  source       = "./modules/lambda"
  project_name = var.project_name
}

# ===========================
# API GATEWAY - Endpoint HTTP
# ===========================
module "api_gateway" {
  source            = "./modules/api_gateway"
  project_name      = var.project_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  lambda_nome       = module.lambda.lambda_nome
}