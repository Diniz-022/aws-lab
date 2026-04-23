variable "api_token" {
  description = "Token da API wdapi2.com.br"
  type        = string
  sensitive   = true
}

variable "email_marcelo" {
  description = "E-mail do Marcelo para receber alertas SNS"
  type        = string
  default     = "marcelo.horikoshi@gmail.com"
}

variable "email_pedro" {
  description = "E-mail do Pedro para receber alertas SNS"
  type        = string
  default     = "pedrohdiniz3@gmail.com"
}
