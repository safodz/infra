variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "create_zone" {
  description = "Create Route53 hosted zone"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "Name of the hosted zone"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "ID of existing hosted zone"
  type        = string
  default     = null
}

variable "records" {
  description = "Map of Route53 records"
  type = map(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
    alias = object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    })
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

