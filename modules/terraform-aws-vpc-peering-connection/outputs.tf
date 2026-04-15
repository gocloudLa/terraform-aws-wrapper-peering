output "vpc_peering_connection_id" {
  description = "ID of `aws_vpc_peering_connection` when `create_peer` is true; null otherwise."
  value       = var.create_peer ? try(aws_vpc_peering_connection.this[0].id, null) : null
}

output "vpc_peering_accepter_id" {
  description = "ID returned by `aws_vpc_peering_connection_accepter` when `create_peer` is false; null otherwise."
  value       = var.create_peer ? null : try(aws_vpc_peering_connection_accepter.this[0].id, null)
}

output "id" {
  description = "Effective VPC peering connection ID (created or accepted)."
  value       = var.create_peer ? try(aws_vpc_peering_connection.this[0].id, null) : try(aws_vpc_peering_connection_accepter.this[0].id, null)
}

output "vpc_peering_route_ids" {
  description = "Map of `aws_route` IDs keyed like `var.routes`."
  value       = { for k, v in aws_route.this : k => v.id }
}
