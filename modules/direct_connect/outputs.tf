output "dx_gateway_id" {
  description = "ID of the Direct Connect Gateway"
  value       = aws_dx_gateway.main.id
}

output "dx_gateway_association_id" {
  description = "ID of the Direct Connect Gateway Association"
  value       = aws_dx_gateway_association.main.id
}

output "dx_connection_id" {
  description = "ID of the Direct Connect Connection"
  value       = var.create_connection ? aws_dx_connection.main[0].id : null
}

output "dx_lag_id" {
  description = "ID of the Direct Connect LAG"
  value       = var.create_lag ? aws_dx_lag.main[0].id : null
}

