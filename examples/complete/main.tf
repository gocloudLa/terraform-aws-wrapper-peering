module "wrapper_peering" {
  source = "../../"

  metadata = local.metadata

  vpc_parameter = var.vpc_parameter

  peering_parameters = {
    "sameAccount" = {
      create_peer = true

      auto_accept = true
      vpc         = "requester"
      #vpc_id       = "vpc-01xxxxxxxxxxxxx"
      vpc_accepter = "accepter"
      # vpc_accepter_id = "vpc-02xxxxxxxxxxxxx"

      requester = {
        allow_remote_vpc_dns_resolution = true
      }
      accepter = {
        allow_remote_vpc_dns_resolution = true
      }

      vpc_routes = {
        requester = {
          private = {
            destination_cidr_block = ["10.20.0.0/16"]
          }
        }
        accepter = {
          private = {
            destination_cidr_block = ["10.10.0.0/16"]
          }
        }
      }
    }

    "crossAccount-requester" = {
      create_peer = true

      vpc = "requester"

      vpc_accepter_id = "vpc-02xxxxxxxxxxxxx" # Remote vpc_id
      peer_owner_id   = "123456789012"        # Remote aws_account_id

      # # Can be enable after peering is Active
      # requester = {
      #   allow_remote_vpc_dns_resolution = true
      # }

      vpc_routes = {
        requester = {
          private = {
            destination_cidr_block = ["10.20.0.0/16"]
          }
        }
      }
    }
  }
}


module "wrapper_peering_accepter" {
  source = "../../"

  metadata = local.metadata

  vpc_parameter = var.vpc_parameter

  peering_parameters = {
    "crossAccount-accepter" = {
      create_peer = false
      auto_accept = true

      peering_id = "pcx-01xxxxxxxxxxxxx"

      # # Can be enable after peering is Active
      # accepter = {
      #   allow_remote_vpc_dns_resolution = true
      # }

      vpc_routes = {
        accepter = {
          private = {
            destination_cidr_block = ["10.10.0.0/16"]
          }
        }
      }
    }
  }
}
