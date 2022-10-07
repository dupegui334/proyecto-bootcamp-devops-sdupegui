# Locals
locals {
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  db_subnet_group = var.db_subnet_group
}

# Random String
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# RDS Instance
resource "aws_db_instance" "database" {
  identifier             = "${var.app}-${random_string.random.result}"
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "microblog"
  username               = var.database_username
  password               = var.database_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = local.db_subnet_group
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Owner : var.owner
  }
}

# EC2 Instances
resource "aws_key_pair" "deployer" {
  key_name   = "${var.owner}-${random_string.random.result}"
  public_key = var.public_key
}

resource "aws_instance" "instances" {
  count                  = var.number_instances
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instances.id]
  subnet_id              = local.private_subnets[count.index]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name  = "${var.app}-${var.owner}-${count.index}"
    Owner = var.owner
  }
}

# Load balancer
resource "aws_lb" "load_balancer" {
  name               = "${var.app}-${random_string.random.result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = local.public_subnets

  tags = {
    Owner = var.owner
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.app}-${random_string.random.result}"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = local.vpc_id
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count            = var.number_instances
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.instances[count.index].id
  port             = 5000
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Elastic IP for Bastion
resource "aws_eip" "bastion_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

# Bastion
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.instances.id, aws_security_group.bastion.id]
  subnet_id                   = element(local.public_subnets, 0)
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name  = "bastion-${var.owner}"
    Owner = var.owner
  }
}

# Security Groups
resource "aws_security_group" "load_balancer" {
  name        = "load-balancer-${random_string.random.result}"
  description = "Security Group asociado al balanceador de carga"
  vpc_id      = local.vpc_id

  tags = {
    Name  = "sg-balanceador",
    Owner = var.owner
  }
}

resource "aws_security_group" "instances" {
  name        = "instances-${random_string.random.result}"
  description = "Security Group asociado a las instancias"
  vpc_id      = local.vpc_id

  tags = {
    Name  = "sg-instancias",
    Owner = var.owner
  }
}

resource "aws_security_group" "database" {
  name        = "database-${random_string.random.result}"
  description = "Security Group asociado a la capa de base de datos"
  vpc_id      = local.vpc_id

  tags = {
    Name  = "sg-database",
    Owner = var.owner
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion-${random_string.random.result}"
  description = "Security Group asociado al bastion"
  vpc_id      = local.vpc_id

  tags = {
    Name  = "sg-bastion",
    Owner = var.owner
  }
}

resource "aws_security_group_rule" "load_balancer_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "instances_load_balancer" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.instances.id
}

resource "aws_security_group_rule" "instances_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.instances.id
}

resource "aws_security_group_rule" "database_instances" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.database.id
}

resource "aws_security_group_rule" "load_balancer_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "instances_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances.id
}

resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.bastion.id
}