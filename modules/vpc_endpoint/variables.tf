variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "endpoints" {
  description = "Map of VPC endpoint configurations"
  type = map(object({
    service_name       = string
    vpc_endpoint_type  = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
    route_table_ids    = list(string)
    private_dns_enabled = bool
    policy            = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

