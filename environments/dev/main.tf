terraform {
  required_version = ">= 1.5.0"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "${var.environment}-${var.project_name}"
  vpc_cidr    = var.vpc_cidr
  tags        = var.tags
}

# Internet Gateway
module "internet_gateway" {
  source = "../../modules/internet_gateway"

  name_prefix = "${var.environment}-${var.project_name}"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

# Public Subnets
module "public_subnets" {
  source = "../../modules/public_subnet"

  name_prefix        = "${var.environment}-${var.project_name}"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits        = 8
  tags               = var.tags
}

# Private Subnets for EC2
module "private_subnets_ec2" {
  source = "../../modules/private_subnet"

  name_prefix        = "${var.environment}-${var.project_name}-ec2"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits        = 8
  start_index        = 2
  tags               = var.tags
}

# Private Subnets for RDS
module "private_subnets_rds" {
  source = "../../modules/private_subnet"

  name_prefix        = "${var.environment}-${var.project_name}-rds"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits        = 8
  start_index        = 4
  tags               = var.tags
}

# NAT Gateways
module "nat_gateways" {
  source = "../../modules/nat_gateway"

  name_prefix         = "${var.environment}-${var.project_name}"
  public_subnet_ids   = module.public_subnets.subnet_ids
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  tags                = var.tags
}

# Route Tables
module "route_tables" {
  source = "../../modules/route_table"

  name_prefix         = "${var.environment}-${var.project_name}"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  public_subnet_ids   = module.public_subnets.subnet_ids
  private_subnet_ids  = concat(module.private_subnets_ec2.subnet_ids, module.private_subnets_rds.subnet_ids)
  nat_gateway_ids     = module.nat_gateways.nat_gateway_ids
  tags                = var.tags
}

# Security Groups
module "alb_sg" {
  source = "../../modules/ec2"

  name_prefix = "${var.environment}-${var.project_name}-alb"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      self            = false
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      self            = false
    }
  ]

  tags = var.tags
}

module "ec2_sg" {
  source = "../../modules/ec2"

  name_prefix = "${var.environment}-${var.project_name}-ec2"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.alb_sg.security_group_id]
      self            = false
    }
  ]

  tags = var.tags
}

module "rds_sg" {
  source = "../../modules/ec2"

  name_prefix = "${var.environment}-${var.project_name}-rds"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.ec2_sg.security_group_id]
      self            = false
    }
  ]

  tags = var.tags
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  name_prefix        = "${var.environment}-${var.project_name}"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.public_subnets.subnet_ids
  security_group_ids = [module.alb_sg.security_group_id]

  target_groups = {
    default = {
      port                      = 80
      protocol                  = "HTTP"
      target_type               = "instance"
      deregistration_delay      = 300
      stickiness_enabled        = false
      stickiness_type           = "lb_cookie"
      stickiness_cookie_duration = 86400
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }

  listeners = {
    http = {
      port            = 80
      protocol        = "HTTP"
      ssl_policy      = null
      certificate_arn = null
      default_action = {
        type             = "forward"
        target_group_arn = "default"
      }
    }
  }

  tags = var.tags
}

# Auto Scaling Group
module "asg" {
  source = "../../modules/asg"

  name_prefix        = "${var.environment}-${var.project_name}"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_ids         = module.private_subnets_ec2.subnet_ids
  security_group_ids = [module.ec2_sg.security_group_id]
  target_group_arns  = [module.alb.target_group_arns["default"]]

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  tags = var.tags
}

# RDS
module "rds" {
  source = "../../modules/rds"

  name_prefix        = "${var.environment}-${var.project_name}"
  subnet_ids         = module.private_subnets_rds.subnet_ids
  security_group_ids = [module.rds_sg.security_group_id]

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  multi_az       = false
  create_standby = false

  tags = var.tags
}

