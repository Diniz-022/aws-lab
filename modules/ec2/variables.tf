variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet"
  type        = string
}

variable "ami" {
  description = "AMI da instancia EC2"
  type        = string
  default     = "ami-0ea87431b78a82070"
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do key pair SSH"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN do bucket S3"
  type        = string
}
