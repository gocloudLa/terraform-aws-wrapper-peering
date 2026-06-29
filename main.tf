module "peering" {
  source = "./modules/terraform-aws-vpc-peering-connection"

  for_each = local.peerings

  create_peer = try(each.value.create_peer, true)

  vpc_id = local.requester_vpc_id[each.key]

  peer_owner_id = try(each.value.peer_owner_id, null)
  peer_vpc_id   = local.accepter_vpc_id[each.key]
  peer_region   = try(each.value.peer_region, null)
  auto_accept   = try(each.value.auto_accept, false)

  vpc_peering_connection_id = try(each.value.peering_id, null)

  requester = try(each.value.requester, {})
  accepter  = try(each.value.accepter, {})

  routes = local.peering_routes[each.key]

  tags = merge(local.common_tags, try(each.value.tags, {}), { Name = "${local.common_name}-${each.key}" }
  )
}
