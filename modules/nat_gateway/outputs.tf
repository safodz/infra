output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_arns" {
  description = "ARNs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].arn
}

output "eip_ids" {
  description = "IDs of the Elastic IPs"
  value       = aws_eip.nat[*].id
}

