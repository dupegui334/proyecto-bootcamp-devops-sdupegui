# AWS Variables
variable "aws_region" {
  description = "La región de AWS"
}

# Custom Variables
variable "owner" {
  description = "Dueño de la app"
}

variable "app" {
  description = "Nombre de la app"
}

variable "number_instances" {
  description = "Número de instancias a crear"
  type        = number
}

variable "database_username" {
  description = "Usuario de la base de datos"
  sensitive   = true
}

variable "database_password" {
  description = "Contraseña de la base de datos"
  sensitive   = true
}

variable "public_key" {
  description = "Llave pública"
  sensitive   = true
}

variable "ami_id" {
  description = "ID de la AMI"
}

variable "vpc_id" {
  description = "ID de la VPC"
}

variable "public_subnets" {
  description = "IDs de las subnets públicas"
}

variable "private_subnets" {
  description = "IDs de las subnets privadas"
}

variable "db_subnet_group" {
  description = "DB Subnet Group"
}

