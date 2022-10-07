# AWS Variables
variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

# Custom Variables
variable "owner" {
  description = "Owner of the app"
}

# VPC Variables
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets_cidr_block" {
  description = "The CIDR block for the private subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_cidr_block" {
  description = "The CIDR block for the public subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "app" {
  description = "Nombre de la app"
  default     = "proyecto-final"
}

variable "number_instances" {
  description = "Número de instancias a crear"
  type        = number
  default     = 2
}

variable "database_username" {
  description = "Usuario de la base de datos"
  default     = "admin"
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
  default     = "ami-05fa00d4c63e32376"
}