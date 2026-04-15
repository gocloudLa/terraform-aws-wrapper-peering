locals {
  peerings = {
    for peering_key, peering_cfg in var.peering_parameters :
    peering_key => merge(var.peering_defaults, peering_cfg)
  }

  requester_vpc_id = {
    for peering_key, peering_cfg in local.peerings :
    peering_key => try(peering_cfg.vpc_id, null) != null ? peering_cfg.vpc_id : try(var.vpc_parameter.vpcs[peering_cfg.vpc].vpc_id, null)
  }

  accepter_vpc_id = {
    for peering_key, peering_cfg in local.peerings :
    peering_key => try(peering_cfg.vpc_accepter_id, null) != null ? peering_cfg.vpc_accepter_id : try(var.vpc_parameter.vpcs[peering_cfg.vpc_accepter].vpc_id, null)
  }

  peering_routes_ipv4_tmp = flatten([
    for peering_key, peering_cfg in local.peerings : [
      for vpc_name, vpc_values in try(peering_cfg.vpc_routes, {}) : [
        for rt_name, rt_values in vpc_values : [
          for cidr in try(tolist(rt_values.destination_cidr_block), []) : {
            peering_key = peering_key
            route_key   = "${peering_key}-${vpc_name}-${rt_name}-4-${replace(cidr, "/", "_")}"
            attrs = {
              route_table_id         = var.vpc_parameter.route_tables["${vpc_name}-${rt_name}"].id
              destination_cidr_block = cidr
            }
          }
        ]
      ]
    ]
  ])

  peering_routes_ipv6_tmp = flatten([
    for peering_key, peering_cfg in local.peerings : [
      for vpc_name, vpc_values in try(peering_cfg.vpc_routes, {}) : [
        for rt_name, rt_values in vpc_values : [
          for cidr in try(tolist(rt_values.destination_ipv6_cidr_block), []) : {
            peering_key = peering_key
            route_key   = "${peering_key}-${vpc_name}-${rt_name}-6-${replace(cidr, "/", "_")}"
            attrs = {
              route_table_id              = var.vpc_parameter.route_tables["${vpc_name}-${rt_name}"].id
              destination_ipv6_cidr_block = cidr
            }
          }
        ]
      ]
    ]
  ])

  peering_route_rows = concat(local.peering_routes_ipv4_tmp, local.peering_routes_ipv6_tmp)

  peering_routes = {
    for peering_key, _ in local.peerings :
    peering_key => {
      for row in local.peering_route_rows :
      row.route_key => row.attrs
      if row.peering_key == peering_key
    }
  }
}
