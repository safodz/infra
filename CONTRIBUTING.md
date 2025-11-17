# Contributing Guide

Thank you for considering contributing to this Terraform infrastructure project!

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/infra.git
   cd infra
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### 1. Make Changes

- Follow Terraform best practices
- Update documentation as needed
- Add comments for complex logic

### 2. Test Locally

```bash
# Format code
terraform fmt -recursive

# Validate modules
cd modules/vpc
terraform init
terraform validate

# Validate environments
cd ../../environments/dev
terraform init
terraform validate
terraform plan
```

### 3. Commit Changes

Follow conventional commits:

```
feat: add new module for S3
fix: correct security group rules
docs: update README
refactor: simplify VPC module
```

### 4. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Code Standards

### Terraform Style

- Use `terraform fmt` before committing
- Follow HashiCorp's style guide
- Use meaningful variable names
- Document all variables and outputs

### Module Structure

Each module should have:
- `main.tf` - Resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- Proper descriptions

### Naming Conventions

- Resources: `snake_case`
- Variables: `snake_case`
- Outputs: `snake_case`
- Tags: `PascalCase` for values

## Pull Request Process

1. Ensure all checks pass
2. Update documentation
3. Add/update tests if applicable
4. Request review from maintainers
5. Address review comments
6. Wait for approval before merging

## Branch Strategy

- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `hotfix/*` - Critical fixes

## Questions?

Open an issue for discussion or questions.

