# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform Peering Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-peering/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-peering.svg?style=for-the-badge" alt="Latest GitHub release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-peering.svg?style=for-the-badge" alt="Last commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-peering/aws/latest"><img src="https://img.shields.io/badge/terraform-registry-blueviolet.svg?style=for-the-badge" alt="Terraform Registry"/></a></p>
Declarative wrapper for Amazon VPC peering: create or accept connections, configure DNS resolution options on both sides, and wire route table entries—all derived from your VPC context map alongside wrapper VPC outputs.


### ✨ Features

- 🔗 [Same-account peering, options, and routes](#same-account-peering,-options,-and-routes) - Create the connection, set requester/accepter options, and publish IPv4/IPv6 routes from one map.

- 🌐 [Cross-account requester and accepter](#cross-account-requester-and-accepter) - Split stacks: one side creates the peering; the other accepts with `peering_id` and optional routes.




## 🚀 Quick Start
```hcl
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
}
```


## 🔧 Additional Features Usage

### Same-account peering, options, and routes
The submodule creates `aws_vpc_peering_connection` when `create_peer` is true, then applies `aws_vpc_peering_connection_options` for requester and accepter DNS resolution flags when you pass non-empty `requester` / `accepter` maps. The wrapper resolves `vpc` and `vpc_accepter` logical names against `vpc_parameter.vpcs`, expands `vpc_routes` into `aws_route` rows using `vpc_parameter.route_tables` keys shaped as `"<vpc>-<route_table>"`, and attaches merged tags including a stable `Name`.


<details><summary>Same-account example (logical VPC names)</summary>

```hcl
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
}
```


</details>


### Cross-account requester and accepter
For another account or a dedicated accepter stack, set `peer_owner_id` and `vpc_accepter_id` on the requester so `aws_vpc_peering_connection` targets the remote VPC. On the peer side, set `create_peer = false`, pass the shared `peering_id`, and use `aws_vpc_peering_connection_accepter` plus `aws_vpc_peering_connection_options` when you supply an `accepter` map. Apply order is inherently multi-step across accounts; DNS options may need the peering to be active before they succeed—plan a follow-up apply if your first run only establishes the connection.


<details><summary>Requester stack (remote VPC id and account)</summary>

```hcl
peering_parameters = {
  "crossAccount-requester" = {
    create_peer = true

    vpc = "requester"

    vpc_accepter_id = "vpc-02xxxxxxxxxxxxx"
    peer_owner_id   = "123456789012"

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
```


</details>

<details><summary>Accepter stack (existing peering id)</summary>

```hcl
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
```


</details>




## 📑 Inputs
| Name            | Description                                                                                                                        | Type        | Default | Required |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------- | -------- |
| vpc             | Logical requester VPC name looked up in `vpc_parameter.vpcs` when `vpc_id` is null.                                                | string      | null    | no       |
| vpc_id          | Explicit requester VPC ID; wins over `vpc` when set.                                                                               | string      | null    | no       |
| vpc_accepter    | Logical accepter VPC name in `vpc_parameter.vpcs` when `vpc_accepter_id` is null.                                                  | string      | null    | no       |
| vpc_accepter_id | Explicit accepter VPC ID; wins over `vpc_accepter` when set.                                                                       | string      | null    | no       |
| peer_owner_id   | AWS account ID owning the peer VPC; omit for same-account peering.                                                                 | string      | null    | no       |
| peer_region     | Peer VPC region for cross-region peering.                                                                                          | string      | null    | no       |
| create_peer     | When true, create `aws_vpc_peering_connection`; when false, accept with `peering_id`.                                              | bool        | true    | no       |
| auto_accept     | Auto-accept peering where supported (same account/region).                                                                         | bool        | false   | no       |
| peering_id      | Existing `pcx-…` ID used when `create_peer` is false.                                                                              | string      | null    | no       |
| requester       | Map forwarded to request-side `aws_vpc_peering_connection_options` (e.g. DNS resolution).                                          | map(any)    | {}      | no       |
| accepter        | Map forwarded to accepter-side options resources.                                                                                  | map(any)    | {}      | no       |
| tags            | Extra tags merged with common metadata tags.                                                                                       | map(string) | {}      | no       |
| vpc_routes      | Nested map: VPC name → route table name → `destination_cidr_block` / `destination_ipv6_cidr_block` lists, expanded to `aws_route`. | map(any)    | {}      | no       |







## ⚠️ Important Notes
- ⚠️ **Cross-account:** Coordinate two applies (or two roots) so the requester creates `pcx-…` before the accepter references `peering_id`; IAM and ownership boundaries are your responsibility outside this module.
- ℹ️ **DNS options:** Example comments keep `requester` / `accepter` blocks disabled until the peering is active—expect a second apply when enabling `allow_remote_vpc_dns_resolution` across accounts.
- 🔒 **Routes:** `vpc_routes` resolves route tables only via `vpc_parameter.route_tables["<vpc>-<rt>"]`; missing keys fail planning—keep naming aligned with your VPC wrapper outputs.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 