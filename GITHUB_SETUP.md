# GitHub Setup Guide

This guide will help you set up this Terraform infrastructure repository on GitHub with CI/CD workflows.

## Prerequisites

1. GitHub repository created
2. AWS account with appropriate permissions
3. AWS IAM roles configured for GitHub Actions (OIDC)

## Step 1: Create GitHub Repository

1. Go to GitHub and create a new repository
2. Initialize it with a README (optional)
3. Clone the repository locally:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

## Step 2: Push Your Code

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: Terraform infrastructure"

# Push to GitHub
git push -u origin main
```

## Step 3: Configure AWS IAM for GitHub Actions (OIDC)

### Create IAM Role for Dev Environment

1. Go to AWS IAM Console
2. Create a new role:
   - Trusted entity type: Web identity
   - Identity provider: GitHub
   - Audience: `sts.amazonaws.com`
   - Repository: `your-username/your-repo-name`
   - Conditions (optional): `repo:your-username/your-repo-name:ref:refs/heads/develop`
3. Attach policies:
   - `AdministratorAccess` (or least privilege policies)
4. Note the Role ARN

### Create IAM Role for Prod Environment

Repeat the above steps for production with:
- Condition: `repo:your-username/your-repo-name:ref:refs/heads/main`

## Step 4: Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

### Required Secrets

1. **AWS_ROLE_TO_ASSUME** (Dev)
   - Value: ARN of the dev IAM role
   - Example: `arn:aws:iam::123456789012:role/github-actions-dev`

2. **AWS_ROLE_TO_ASSUME_PROD** (Prod)
   - Value: ARN of the prod IAM role
   - Example: `arn:aws:iam::123456789012:role/github-actions-prod`

### Optional Secrets

- `TF_VAR_rds_password` - RDS password (if using secrets)
- `TF_VAR_aws_region` - AWS region override

## Step 5: Configure Terraform Backend

Edit `backend.tf`:

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

### Create S3 Bucket for State

```bash
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### Create DynamoDB Table for Locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Step 6: Create Environment-Specific Variables

### Dev Environment

Create `environments/dev/terraform.tfvars.example`:

```hcl
environment = "dev"
project_name = "myproject"
aws_region   = "us-east-1"
vpc_cidr     = "10.1.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]

instance_type = "t3.small"

rds_engine         = "postgres"
rds_engine_version = "15.4"
rds_instance_class = "db.t3.micro"
rds_db_name        = "mydb"
rds_username       = "admin"
rds_password       = "CHANGE_ME"

tags = {
  Environment = "development"
  Project     = "myproject"
  Team        = "engineering"
}
```

### Prod Environment

Create `environments/prod/terraform.tfvars.example`:

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
rds_password       = "CHANGE_ME"

tags = {
  Environment = "production"
  Project     = "myproject"
  Team        = "engineering"
}
```

## Step 7: Branch Strategy

### Recommended Branch Structure

- `main` / `master` → Production environment
- `develop` / `dev` → Development environment
- `feature/*` → Feature branches
- `hotfix/*` → Hotfix branches

### Workflow

1. **Development**: Work on `develop` branch
   - Pushes trigger dev workflow
   - Auto-applies on merge to `develop`

2. **Production**: Merge `develop` → `main`
   - Requires manual approval or workflow_dispatch
   - More controlled deployment

## Step 8: Test the Workflow

### Test Dev Environment

1. Create a feature branch:
   ```bash
   git checkout -b feature/test-dev
   ```

2. Make a small change (e.g., update a tag)

3. Push and create PR:
   ```bash
   git push origin feature/test-dev
   ```

4. The workflow will:
   - Run format check
   - Run validation
   - Create a plan
   - Comment on the PR

5. After merge to `develop`, it will auto-apply

### Test Prod Environment

1. Merge `develop` → `main` via PR
2. Review the plan in PR comments
3. After merge, it will auto-apply (or use workflow_dispatch for manual control)

## Step 9: Manual Deployment (Optional)

You can also trigger workflows manually:

1. Go to Actions tab
2. Select the workflow (e.g., "Terraform - Prod Environment")
3. Click "Run workflow"
4. Choose branch and whether to apply
5. Click "Run workflow"

## Security Best Practices

1. **Never commit secrets**:
   - Use GitHub Secrets for sensitive values
   - Use AWS Secrets Manager or Parameter Store
   - Add `.tfvars` to `.gitignore`

2. **Least Privilege IAM**:
   - Create specific IAM policies
   - Don't use `AdministratorAccess` in production
   - Use separate roles for dev/prod

3. **Branch Protection**:
   - Enable branch protection on `main`
   - Require PR reviews
   - Require status checks

4. **State File Security**:
   - Enable S3 bucket encryption
   - Enable versioning
   - Use DynamoDB for locking

## Troubleshooting

### Workflow Fails on Init

- Check backend configuration
- Verify S3 bucket exists
- Check IAM permissions

### Workflow Fails on Plan/Apply

- Check AWS credentials
- Verify IAM role ARN in secrets
- Check OIDC trust relationship

### State Lock Issues

- Check DynamoDB table exists
- Verify table permissions
- Manually release lock if needed:
  ```bash
  terraform force-unlock <LOCK_ID>
  ```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Cloud](https://www.terraform.io/cloud) (Alternative to S3 backend)
- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## Support

For issues or questions, please open an issue in this repository.

