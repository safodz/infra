variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = ""
}

variable "domain_name_servers" {
  description = "List of domain name servers"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "ntp_servers" {
  description = "List of NTP servers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

