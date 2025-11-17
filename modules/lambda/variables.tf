variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "source_file" {
  description = "Path to source file for Lambda function"
  type        = string
  default     = null
}

variable "filename" {
  description = "Path to deployment package"
  type        = string
  default     = null
}

variable "create_zip" {
  description = "Create zip file from source"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC configuration"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC configuration"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "iam_policy_statements" {
  description = "IAM policy statements for Lambda function"
  type        = list(any)
  default     = []
}

variable "api_gateway_source_arn" {
  description = "API Gateway source ARN for Lambda permission"
  type        = string
  default     = null
}

variable "dynamodb_stream_arn" {
  description = "DynamoDB stream ARN for Lambda permission"
  type        = string
  default     = null
}

variable "dynamodb_batch_size" {
  description = "Batch size for DynamoDB stream event source mapping"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

