output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.main : k => v.id }
}

output "vpc_endpoint_arns" {
  description = "ARNs of the VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.main : k => v.arn }
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries of the VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.main : k => v.dns_entry }
}

