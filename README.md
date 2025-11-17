# AWS Infrastructure as Code with Terraform

This repository contains Terraform modules and configurations for deploying a comprehensive AWS infrastructure based on best practices.

## Architecture Overview

This infrastructure implements a multi-AZ AWS architecture with:

- **VPC** with public and private subnets across multiple availability zones
- **Internet Gateway** for public internet access
- **NAT Gateways** for private subnet internet access
- **Application Load Balancer** for distributing traffic
- **Auto Scaling Group** with EC2 instances
- **RDS** database with Multi-AZ support and standby instance
- **DynamoDB** table with streams enabled
- **Lambda** function triggered by DynamoDB streams
- **API Gateway** for REST API endpoints
- **VPC Endpoints** for private DynamoDB access
- **Transit Gateway** (optional) for VPC connectivity
- **Direct Connect** (optional) for on-premise connectivity
- **VPN Gateway** (optional) for site-to-site VPN
- **Route53** (optional) for DNS management
- **CloudFront** (optional) for CDN

## Project Structure

```
infra/
├── modules/              # Reusable Terraform modules
│   ├── alb/             # Application Load Balancer
│   ├── api_gateway/     # API Gateway
│   ├── asg/             # Auto Scaling Group
│   ├── cloudfront/      # CloudFront Distribution
│   ├── direct_connect/  # Direct Connect
│   ├── dynamodb/        # DynamoDB Table
│   ├── ec2/             # Security Groups
│   ├── internet_gateway/# Internet Gateway
│   ├── lambda/          # Lambda Function
│   ├── nat_gateway/     # NAT Gateway
│   ├── private_subnet/  # Private Subnets
│   ├── public_subnet/   # Public Subnets
│   ├── rds/             # RDS Database
│   ├── route53/         # Route53
│   ├── route_table/     # Route Tables
│   ├── transit_gateway/ # Transit Gateway
│   ├── vpc/             # VPC
│   ├── vpc_endpoint/    # VPC Endpoints
│   └── vpn/             # VPN Gateway
├── environments/        # Environment-specific configurations
│   ├── dev/            # Development environment
│   └── prod/           # Production environment
├── backend.tf           # Terraform backend configuration
├── providers.tf        # Provider configuration
├── variables.tf        # Root variables
└── versions.tf         # Terraform version requirements
```

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## Quick Start

### For GitHub Deployment

See [GITHUB_SETUP.md](./GITHUB_SETUP.md) for complete GitHub Actions setup instructions.

### For Local Deployment

## Getting Started

### 1. Configure Backend

Edit `backend.tf` to configure your S3 backend for state management:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 2. Configure Variables

Create a `terraform.tfvars` file in the environment directory (e.g., `environments/prod/terraform.tfvars`):

```hcl
environment = "prod"
project_name = "myproject"
aws_region   = "us-east-1"
vpc_cidr     = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]

instance_type = "t3.medium"

asg_min_size         = 2
asg_max_size         = 10
asg_desired_capacity = 2

rds_engine         = "postgres"
rds_engine_version = "15.4"
rds_instance_class = "db.t3.medium"
rds_db_name        = "mydb"
rds_username       = "admin"
rds_password       = "your-secure-password"

tags = {
  Environment = "production"
  Project     = "myproject"
  Team        = "engineering"
}
```

### 3. Initialize Terraform

```bash
cd environments/prod
terraform init
```

### 4. Plan Deployment

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply
```

## Module Usage

Each module is designed to be reusable and follows Terraform best practices:

- **Variables**: Well-documented input variables
- **Outputs**: Comprehensive outputs for integration
- **Tags**: Consistent tagging strategy
- **Security**: Security best practices implemented

## Best Practices Implemented

1. **Modular Design**: Reusable modules for each AWS service
2. **Environment Separation**: Separate configurations for dev/prod
3. **Security**: Security groups with least privilege, encrypted storage
4. **High Availability**: Multi-AZ deployment for critical services
5. **Scalability**: Auto Scaling Groups with CloudWatch alarms
6. **Monitoring**: CloudWatch logs and metrics enabled
7. **Backup**: RDS automated backups and point-in-time recovery
8. **Tagging**: Consistent tagging across all resources
9. **State Management**: Remote state with locking
10. **Version Control**: Terraform version pinning

## Security Considerations

- Security groups follow least privilege principle
- RDS instances are in private subnets
- Database encryption at rest enabled
- DynamoDB encryption enabled
- VPC endpoints for private AWS service access
- IAM roles with minimal required permissions

## Cost Optimization

- NAT Gateways can be conditionally created
- Optional services (Transit Gateway, Direct Connect) are feature flags
- Auto Scaling to adjust capacity based on demand
- RDS Multi-AZ can be disabled in dev environment

## Maintenance

### Updating Modules

When updating modules, ensure backward compatibility or update all references.

### State Management

Always use remote state with locking to prevent conflicts.

### Secrets Management

Use AWS Secrets Manager or Parameter Store for sensitive values like database passwords.

## Troubleshooting

### Common Issues

1. **State Lock**: If state is locked, check DynamoDB table for stale locks
2. **Provider Version**: Ensure AWS provider version is compatible
3. **Permissions**: Verify IAM permissions for Terraform execution
4. **CIDR Conflicts**: Ensure VPC CIDR blocks don't overlap

## Contributing

1. Follow Terraform best practices
2. Document all variables and outputs
3. Test modules in isolation before integration
4. Update README for new features

## License

This project is licensed under the MIT License.
