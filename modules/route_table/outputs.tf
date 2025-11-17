output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_public ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.create_private ? aws_route_table.private[*].id : []
}

