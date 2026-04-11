variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "limit_amount" {
  description = "Limite de custo mensal em USD"
  type        = string
  default     = "20"
}

variable "email_alerta" {
  description = "Email para receber alertas de custo"
  type        = string
}
