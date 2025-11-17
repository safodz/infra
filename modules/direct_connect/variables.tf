variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "amazon_side_asn" {
  description = "The ASN to be configured on the Amazon side of the connection"
  type        = number
  default     = 64512
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to associate with"
  type        = string
  default     = null
}

variable "vpn_gateway_id" {
  description = "ID of the VPN Gateway to associate with"
  type        = string
  default     = null
}

variable "allowed_prefixes" {
  description = "VPC prefixes to advertise to the Direct Connect gateway"
  type        = list(string)
  default     = []
}

variable "create_connection" {
  description = "Create Direct Connect connection"
  type        = bool
  default     = false
}

variable "create_lag" {
  description = "Create Direct Connect LAG"
  type        = bool
  default     = false
}

variable "bandwidth" {
  description = "The bandwidth of the connection"
  type        = string
  default     = "1Gbps"
}

variable "location" {
  description = "The AWS Direct Connect location in which to create the connection"
  type        = string
  default     = ""
}

variable "number_of_connections" {
  description = "The number of physical connections initially provisioned and bundled by the LAG"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

