output "zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = var.create_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
}

output "zone_name_servers" {
  description = "Name servers of the Route53 hosted zone"
  value       = var.create_zone ? aws_route53_zone.main[0].name_servers : []
}

