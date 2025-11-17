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

  name_prefix       = "${var.environment}-${var.project_name}"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits       = 8
  tags              = var.tags
}

# Private Subnets for EC2
module "private_subnets_ec2" {
  source = "../../modules/private_subnet"

  name_prefix       = "${var.environment}-${var.project_name}-ec2"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits       = 8
  start_index       = 2
  tags              = var.tags
}

# Private Subnets for RDS
module "private_subnets_rds" {
  source = "../../modules/private_subnet"

  name_prefix       = "${var.environment}-${var.project_name}-rds"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_bits       = 8
  start_index       = 4
  tags              = var.tags
}

# NAT Gateways
module "nat_gateways" {
  source = "../../modules/nat_gateway"

  name_prefix          = "${var.environment}-${var.project_name}"
  public_subnet_ids    = module.public_subnets.subnet_ids
  internet_gateway_id  = module.internet_gateway.internet_gateway_id
  tags                 = var.tags
}

# Route Tables
module "route_tables" {
  source = "../../modules/route_table"

  name_prefix          = "${var.environment}-${var.project_name}"
  vpc_id               = module.vpc.vpc_id
  internet_gateway_id  = module.internet_gateway.internet_gateway_id
  public_subnet_ids    = module.public_subnets.subnet_ids
  private_subnet_ids   = concat(module.private_subnets_ec2.subnet_ids, module.private_subnets_rds.subnet_ids)
  nat_gateway_ids      = module.nat_gateways.nat_gateway_ids
  tags                 = var.tags
}

# Security Groups
module "alb_sg" {
  source = "../../modules/ec2"

  name_prefix = "${var.environment}-${var.project_name}-alb"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port      = 80
      to_port        = 80
      protocol       = "tcp"
      cidr_blocks    = ["0.0.0.0/0"]
      security_groups = []
      self           = false
    },
    {
      from_port      = 443
      to_port        = 443
      protocol       = "tcp"
      cidr_blocks    = ["0.0.0.0/0"]
      security_groups = []
      self           = false
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
      from_port      = 80
      to_port        = 80
      protocol       = "tcp"
      cidr_blocks    = []
      security_groups = [module.alb_sg.security_group_id]
      self           = false
    },
    {
      from_port      = 443
      to_port        = 443
      protocol       = "tcp"
      cidr_blocks    = []
      security_groups = [module.alb_sg.security_group_id]
      self           = false
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
      from_port      = 5432
      to_port        = 5432
      protocol       = "tcp"
      cidr_blocks    = []
      security_groups = [module.ec2_sg.security_group_id]
      self           = false
    }
  ]

  tags = var.tags
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  name_prefix       = "${var.environment}-${var.project_name}"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.public_subnets.subnet_ids
  security_group_ids = [module.alb_sg.security_group_id]

  target_groups = {
    default = {
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      stickiness_enabled   = false
      stickiness_type      = "lb_cookie"
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
      port     = 80
      protocol = "HTTP"
      ssl_policy = null
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

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  tags = var.tags
}

# RDS
module "rds" {
  source = "../../modules/rds"

  name_prefix       = "${var.environment}-${var.project_name}"
  subnet_ids        = module.private_subnets_rds.subnet_ids
  security_group_ids = [module.rds_sg.security_group_id]

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  multi_az        = true
  create_standby  = true
  standby_availability_zone = var.availability_zones[1]

  tags = var.tags
}

# VPC Endpoints for DynamoDB
module "vpc_endpoints" {
  source = "../../modules/vpc_endpoint"

  name_prefix = "${var.environment}-${var.project_name}"
  vpc_id      = module.vpc.vpc_id

  endpoints = {
    dynamodb = {
      service_name        = "com.amazonaws.${var.aws_region}.dynamodb"
      vpc_endpoint_type   = "Gateway"
      subnet_ids          = []
      security_group_ids  = []
      route_table_ids     = concat(
        [module.route_tables.public_route_table_id],
        module.route_tables.private_route_table_ids
      )
      private_dns_enabled = false
      policy              = null
    }
  }

  tags = var.tags
}

# DynamoDB
module "dynamodb" {
  source = "../../modules/dynamodb"

  name_prefix = "${var.environment}-${var.project_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = var.tags
}

# Lambda Function
module "lambda" {
  source = "../../modules/lambda"

  name_prefix = "${var.environment}-${var.project_name}"
  handler     = "index.handler"
  runtime     = "python3.11"
  timeout     = 30
  memory_size = 256

  subnet_ids         = module.private_subnets_ec2.subnet_ids
  security_group_ids = [module.ec2_sg.security_group_id]

  dynamodb_stream_arn = module.dynamodb.stream_arn
  dynamodb_batch_size = 10

  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Resource = [
        module.dynamodb.table_arn,
        "${module.dynamodb.table_arn}/*"
      ]
    }
  ]

  tags = var.tags
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api_gateway"

  name_prefix = "${var.environment}-${var.project_name}"
  description = "API Gateway for ${var.environment} environment"

  resources = {
    proxy = {
      parent_id = "ROOT"
      path_part = "{proxy+}"
    }
  }

  methods = {
    proxy = {
      resource_id  = "proxy"
      http_method   = "ANY"
      authorization = "NONE"
      authorizer_id = null
    }
  }

  integrations = {
    proxy = {
      resource_id          = "proxy"
      http_method          = "ANY"
      integration_type     = "AWS_PROXY"
      integration_http_method = "POST"
      uri                  = module.lambda.lambda_function_invoke_arn
      connection_type      = null
      connection_id        = null
    }
  }

  depends_on = [module.lambda]

  tags = var.tags
}

# Transit Gateway (optional)
module "transit_gateway" {
  count  = var.enable_transit_gateway ? 1 : 0
  source = "../../modules/transit_gateway"

  name_prefix = "${var.environment}-${var.project_name}"
  tags        = var.tags
}

# Direct Connect (optional)
module "direct_connect" {
  count  = var.enable_direct_connect ? 1 : 0
  source = "../../modules/direct_connect"

  name_prefix        = "${var.environment}-${var.project_name}"
  transit_gateway_id = var.enable_transit_gateway ? module.transit_gateway[0].transit_gateway_id : null
  tags               = var.tags
}

# VPN (optional)
module "vpn" {
  count  = var.enable_vpn_gateway ? 1 : 0
  source = "../../modules/vpn"

  name_prefix = "${var.environment}-${var.project_name}"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

# Route53 (optional)
module "route53" {
  count  = var.enable_route53 ? 1 : 0
  source = "../../modules/route53"

  name_prefix = "${var.environment}-${var.project_name}"
  create_zone = var.create_route53_zone
  zone_name   = var.route53_zone_name

  records = {
    alb = {
      name    = var.route53_record_name
      type    = "A"
      ttl     = 300
      records = []
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }
  }

  tags = var.tags
}

# CloudFront (optional)
module "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  source = "../../modules/cloudfront"

  name_prefix        = "${var.environment}-${var.project_name}"
  origin_domain_name = module.alb.alb_dns_name
  origin_id          = "alb-origin"

  aliases = var.cloudfront_aliases

  tags = var.tags
}
