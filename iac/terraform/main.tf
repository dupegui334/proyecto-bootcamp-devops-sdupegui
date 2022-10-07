module "networking" {
  source                     = "./networking"
  aws_region                 = var.aws_region
  owner                      = var.owner
  vpc_cidr_block             = var.vpc_cidr_block
  private_subnets_cidr_block = var.private_subnets_cidr_block
  public_subnets_cidr_block  = var.public_subnets_cidr_block
}

module "app" {
  source            = "./app"
  aws_region        = var.aws_region
  owner             = var.owner
  app               = var.app
  number_instances  = var.number_instances
  database_username = var.database_username
  database_password = var.database_password
  public_key        = var.public_key
  ami_id            = var.ami_id

  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  db_subnet_group = module.networking.db_subnet_group
}