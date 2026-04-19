module "wrapper_peering" {
  source = "../../"

  metadata = local.metadata

  vpc_parameter = var.vpc_parameter

  vpc_peering_parameters = {
    "sameAccount" = {
      create_peer = true

      auto_accept = true
      vpc         = "requester"
      #vpc_id       = "vpc-01xxxxxxxxxxxxx"
      vpc_accepter = "accepter"
      # vpc_accepter_id = "vpc-02xxxxxxxxxxxxx"
      #peer_region  = "us-east-2"

      requester = {
        allow_remote_vpc_dns_resolution = true
      }
      accepter = {
        allow_remote_vpc_dns_resolution = true
      }

      vpc_routes = {
        requester = {
          private = {
            destination_cidr_block = ["X.X.0.0/16"]
          }
        }
      }
    }

    "crossAccount-local" = {
      create_peer = true

      vpc = "requester"

      vpc_accepter_id = "vpc-02xxxxxxxxxxxxx" # Remote vpc_id
      peer_owner_id   = "123456789012"        # Remote aws_account_id

      vpc_routes = {
        requester = {
          private = {
            destination_cidr_block = ["X.X.0.0/16"]
          }
        }
      }
    }
  }
}


module "wrapper_peering" {
  source = "../../"

  metadata = local.metadata

  vpc_parameter = var.vpc_parameter

  vpc_peering_parameters = {
    "crossAccount-remote" = {
      create_peer = false
      auto_accept = true

      peering_id = "pcx-01xxxxxxxxxxxxx"

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