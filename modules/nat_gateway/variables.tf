variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for NAT Gateways"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

