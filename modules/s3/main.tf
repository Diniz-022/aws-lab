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
