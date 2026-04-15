/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type        = any
  description = "Platform metadata (company, env, project, regions, tags)."
}

/*----------------------------------------------------------------------*/
/* VPC context | from wrapper-vpc or equivalent outputs */
/*----------------------------------------------------------------------*/

variable "vpc_parameter" {
  type        = any
  description = "VPC outputs: `vpcs` map (name => { vpc_id }) and `route_tables` map (\"<vpc>-<rt>\" => { id })."
  default     = {}
}

/*----------------------------------------------------------------------*/
/* VPC peering                                                          */
/*----------------------------------------------------------------------*/

variable "vpc_peering_parameters" {
  type        = any
  description = "Map of peering connections keyed by logical name."
  default     = {}
}

variable "vpc_peering_defaults" {
  type        = any
  description = "Default values merged into each entry of `vpc_peering_parameters`."
  default     = {}
}
