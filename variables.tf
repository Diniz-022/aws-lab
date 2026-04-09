variable "region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado para nomear os recursos"
  type        = string
  default     = "aws-lab"
}

variable "email_alerta" {
  description = "Email para receber alertas de custo"
  type        = string
  default     = "pedrohdiniz3@gmail.com"
}