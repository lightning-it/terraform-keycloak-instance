variable "realms" {
  description = "Map of realms keyed by name."
  type = map(object({
    id    = string
    realm = string
  }))
}

variable "clients" {
  description = "List of Keycloak clients to configure for this instance."
  type = list(object({
    client_id                    = string
    client_type                  = string
    name                         = optional(string)
    realm                        = optional(string)
    redirect_uris                = optional(list(string))
    web_origins                  = optional(list(string))
    base_url                     = optional(string)
    standard_flow_enabled        = optional(bool)
    implicit_flow_enabled        = optional(bool)
    direct_access_grants_enabled = optional(bool)
    service_accounts_enabled     = optional(bool)
    frontchannel_logout_enabled  = optional(bool)
    default_scopes               = optional(list(string))
    optional_scopes              = optional(list(string))
  }))
  default = []
}

variable "service_accounts" {
  description = "Configuration for client service accounts, including optional role assignments."
  type = list(object({
    client_id    = string
    realm        = optional(string)
    enabled      = optional(bool)
    attributes   = optional(map(list(string)))
    realm_roles  = optional(list(string))
    client_roles = optional(map(list(string)))
  }))
  default = []
}

variable "client_scopes" {
  description = "List of reusable client scopes."
  type = list(object({
    name        = string
    realm       = optional(string)
    description = optional(string)
    protocol    = optional(string)
    mappers = optional(list(object({
      name             = string
      protocol         = optional(string)
      protocol_mapper  = string
      consent_required = optional(bool)
      consent_text     = optional(string)
      config           = optional(map(string))
    })))
  }))
  default = []
}
