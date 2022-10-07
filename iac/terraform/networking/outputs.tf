output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Subredes publicas"
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "Subredes privadas"
  value       = aws_subnet.private.*.id
}

output "db_subnet_group" {
  description = "Grupo de subredes de la base de datos"
  value       = aws_db_subnet_group.main.name
}