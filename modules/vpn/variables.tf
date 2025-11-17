variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "create_vpn_gateway" {
  description = "Create VPN Gateway"
  type        = bool
  default     = true
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = number
  default     = 64512
}

variable "customer_gateways" {
  description = "Map of customer gateway configurations"
  type = map(object({
    bgp_asn         = number
    ip_address      = string
    type            = string
    static_routes_only = bool
    static_routes   = list(string)
  }))
  default = {}
}

variable "vpn_routes" {
  description = "Map of VPN routes"
  type = map(object({
    destination_cidr_block = string
    vpn_connection_key     = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

