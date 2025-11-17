output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "customer_gateway_ids" {
  description = "IDs of the Customer Gateways"
  value       = { for k, v in aws_customer_gateway.main : k => v.id }
}

output "vpn_connection_ids" {
  description = "IDs of the VPN Connections"
  value       = var.create_vpn_gateway ? { for k, v in aws_vpn_connection.main : k => v.id } : {}
}

