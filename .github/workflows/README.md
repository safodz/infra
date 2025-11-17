# GitHub Actions Workflows

This directory contains GitHub Actions workflows for CI/CD automation.

## Workflows

### 1. Terraform Dev (`terraform-dev.yml`)
- **Triggers**: Pushes/PRs to `develop` or `dev` branches
- **Actions**: Format check, validate, plan, and auto-apply
- **Environment**: Development

### 2. Terraform Prod (`terraform-prod.yml`)
- **Triggers**: Pushes/PRs to `main`, `master`, or `production` branches
- **Actions**: Format check, validate, plan, and apply (with manual approval option)
- **Environment**: Production

### 3. Terraform Lint (`terraform-lint.yml`)
- **Triggers**: Any push/PR with Terraform file changes
- **Actions**: Format check, validation, and sensitive data detection
- **Purpose**: Code quality checks

### 4. Security Scan (`security-scan.yml`)
- **Triggers**: Weekly schedule and on push/PR
- **Actions**: TFSec and Checkov security scans
- **Purpose**: Security vulnerability detection

## Required Secrets

Configure these in GitHub repository settings:

- `AWS_ROLE_TO_ASSUME` - IAM role ARN for dev environment
- `AWS_ROLE_TO_ASSUME_PROD` - IAM role ARN for prod environment

## Workflow Features

- ✅ Automatic Terraform formatting checks
- ✅ Validation before plan/apply
- ✅ PR comments with plan output
- ✅ Artifact storage for plans
- ✅ Security scanning
- ✅ OIDC authentication (no long-lived credentials)

## Manual Trigger

You can manually trigger workflows from the Actions tab:
1. Go to Actions
2. Select workflow
3. Click "Run workflow"
4. Choose options and run

