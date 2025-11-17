terraform {
  backend "s3" {
    # Configure your S3 backend here
    # bucket         = "your-terraform-state-bucket"
    # key            = "infrastructure/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "terraform-state-lock"
  }
}

