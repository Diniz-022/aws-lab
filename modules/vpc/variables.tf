variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "region" {
  description = "Regiao AWS"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  description = "CIDR da subnet publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_privada_cidr" {
  description = "CIDR da subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}
