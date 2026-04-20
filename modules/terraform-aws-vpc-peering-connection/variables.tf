variable "create_peer" {
  type        = bool
  default     = true
  description = "If true, create `aws_vpc_peering_connection`. If false, use `aws_vpc_peering_connection_accepter` with `peering_id`."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "Requester VPC ID (required when `create_peer` is true)."

  validation {
    condition     = !var.create_peer || (var.vpc_id != null && var.vpc_id != "")
    error_message = "vpc_id is required when create_peer is true."
  }
}

variable "peer_vpc_id" {
  type        = string
  default     = null
  description = "Peer (accepter) VPC ID (required when `create_peer` is true)."

  validation {
    condition     = !var.create_peer || (var.peer_vpc_id != null && var.peer_vpc_id != "")
    error_message = "peer_vpc_id is required when create_peer is true."
  }
}

variable "peer_owner_id" {
  type        = string
  default     = null
  description = "AWS account ID of the peer VPC owner. Defaults to current account when null and `create_peer` is true."
}

variable "peer_region" {
  type        = string
  default     = null
  description = "Region of the peer VPC for cross-region peering."
}

variable "auto_accept" {
  type        = bool
  default     = false
  description = "Auto-accept the peering request (same account/region)."
}

variable "requester" {
  type        = any
  default     = {}
  description = "Optional `requester` block: e.g. `{ allow_remote_vpc_dns_resolution = true }`."
}

variable "accepter" {
  type        = any
  default     = {}
  description = "Optional `accepter` block on the connection resource when `create_peer` is true."
}

variable "vpc_peering_connection_id" {
  type        = string
  default     = null
  description = "Existing peering connection ID (required when `create_peer` is false)."

  validation {
    condition     = var.create_peer || (var.vpc_peering_connection_id != null && var.vpc_peering_connection_id != "")
    error_message = "vpc_peering_connection_id is required when create_peer is false."
  }
}

variable "routes" {
  type = map(object({
    route_table_id              = string
    destination_cidr_block      = optional(string)
    destination_ipv6_cidr_block = optional(string)
  }))
  default     = {}
  description = "Routes to create pointing at this peering connection."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for peering resources."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Optional timeouts for `aws_vpc_peering_connection`."
}
