variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
  default     = null
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs for private routes"
  type        = list(string)
  default     = null
}

variable "create_public" {
  description = "Create public route table"
  type        = bool
  default     = true
}

variable "create_private" {
  description = "Create private route tables"
  type        = bool
  default     = true
}

variable "additional_routes" {
  description = "Additional routes to add to route tables"
  type = list(object({
    cidr_block                = string
    gateway_id                = string
    nat_gateway_id            = string
    vpc_peering_connection_id = string
    transit_gateway_id        = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

