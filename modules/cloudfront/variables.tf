variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class"
  type        = string
  default     = "PriceClass_All"
}

variable "aliases" {
  description = "List of aliases"
  type        = list(string)
  default     = []
}

variable "origin_domain_name" {
  description = "Domain name of the origin"
  type        = string
}

variable "origin_id" {
  description = "ID of the origin"
  type        = string
  default     = "default-origin"
}

variable "custom_origin_config" {
  description = "Custom origin configuration"
  type = object({
    http_port              = number
    https_port             = number
    origin_protocol_policy = string
    origin_ssl_protocols   = list(string)
  })
  default = {
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"
    origin_ssl_protocols   = ["TLSv1.2"]
  }
}

variable "default_cache_behavior" {
  description = "Default cache behavior configuration"
  type = object({
    allowed_methods  = list(string)
    cached_methods   = list(string)
    target_origin_id = string
    compress         = bool
    forwarded_values = object({
      query_string   = bool
      headers        = list(string)
      cookies_forward = string
    })
    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
  })
  default = {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "default-origin"
    compress         = true
    forwarded_values = {
      query_string   = false
      headers        = []
      cookies_forward = "none"
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}

variable "geo_restriction" {
  description = "Geo restriction configuration"
  type = object({
    restriction_type = string
    locations        = list(string)
  })
  default = {
    restriction_type = "none"
    locations        = []
  }
}

variable "viewer_certificate" {
  description = "Viewer certificate configuration"
  type = object({
    acm_certificate_arn      = string
    ssl_support_method       = string
    minimum_protocol_version = string
  })
  default = {
    acm_certificate_arn      = ""
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

