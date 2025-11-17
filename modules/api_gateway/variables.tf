variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway managed by Terraform"
}

variable "endpoint_type" {
  description = "Endpoint type (REGIONAL, EDGE, PRIVATE)"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "Stage name for deployment"
  type        = string
  default     = "prod"
}

variable "resources" {
  description = "Map of API Gateway resources"
  type = map(object({
    parent_id = string
    path_part = string
  }))
  default = {}
}

variable "methods" {
  description = "Map of API Gateway methods"
  type = map(object({
    resource_id  = string
    http_method   = string
    authorization = string
    authorizer_id = string
  }))
  default = {}
}

variable "integrations" {
  description = "Map of API Gateway integrations"
  type = map(object({
    resource_id          = string
    http_method          = string
    integration_type     = string
    integration_http_method = string
    uri                  = string
    connection_type      = string
    connection_id        = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

