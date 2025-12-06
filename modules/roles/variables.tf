variable "realms" {
  description = "Map of realms keyed by name."
  type = map(object({
    id    = string
    realm = string
  }))
}

variable "clients" {
  description = "Map of configured clients keyed by client_id."
  type = map(object({
    id        = string
    realm     = string
    client_id = string
  }))
  default = {}
}

variable "realm_roles" {
  description = "Realm-level roles to configure."
  type = list(object({
    name        = string
    realm       = optional(string)
    description = optional(string)
    composite   = optional(bool)
    composites  = optional(list(string))
  }))
  default = []
}

variable "client_roles" {
  description = "Client-specific roles to configure."
  type = list(object({
    client_id   = string
    name        = string
    realm       = optional(string)
    description = optional(string)
    composite   = optional(bool)
    composites  = optional(list(string))
  }))
  default = []
}
