resource "aws_vpc_peering_connection" "this" {
  count = var.create_peer ? 1 : 0

  vpc_id = var.vpc_id

  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region

  auto_accept = var.auto_accept

  tags = var.tags
}

resource "aws_vpc_peering_connection_accepter" "this" {
  count = var.create_peer ? 0 : 1

  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = var.auto_accept

  tags = var.tags
}

resource "aws_vpc_peering_connection_options" "accepter" {
  count = var.create_peer ? 1 : 0

  vpc_peering_connection_id = var.create_peer ? aws_vpc_peering_connection.this[0].id : null

  dynamic "requester" {
    for_each = length(keys(try(var.requester, {}))) > 0 ? [var.requester] : []
    content {
      allow_remote_vpc_dns_resolution = try(requester.value.allow_remote_vpc_dns_resolution, null)
    }
  }

  dynamic "accepter" {
    for_each = length(keys(try(var.accepter, {}))) > 0 ? [var.accepter] : []
    content {
      allow_remote_vpc_dns_resolution = try(accepter.value.allow_remote_vpc_dns_resolution, null)
    }
  }
}

resource "aws_route" "this" {
  for_each = var.routes

  route_table_id              = each.value.route_table_id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  vpc_peering_connection_id   = var.create_peer ? aws_vpc_peering_connection.this[0].id : aws_vpc_peering_connection_accepter.this[0].id
}
