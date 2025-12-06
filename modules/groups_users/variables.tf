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
    id                      = string
    realm                   = string
    client_id               = string
    service_account_user_id = string
  }))
  default = {}
}

variable "realm_roles" {
  description = "Map of configured realm roles keyed by \"<realm>:<role_name>\"."
  type = map(object({
    id    = string
    realm = string
    name  = string
  }))
  default = {}
}

variable "client_roles" {
  description = "Map of configured client roles keyed by \"<client_id>:<role_name>\"."
  type = map(object({
    id        = string
    realm     = string
    client_id = string
    name      = string
  }))
  default = {}
}

variable "groups" {
  description = "List of Keycloak groups to create, including optional attributes and hierarchy."
  type = list(object({
    name       = string
    realm      = optional(string)
    parent     = optional(string)
    attributes = optional(map(list(string)))
    path       = optional(string)
  }))
  default = []
}

variable "default_groups" {
  description = "Default groups to assign to new users per realm."
  type = list(object({
    realm = string
    names = list(string)
  }))
  default = []
}

variable "users" {
  description = "List of users to seed in Keycloak, including credentials and attributes."
  type = list(object({
    username         = string
    realm            = optional(string)
    enabled          = optional(bool)
    email            = optional(string)
    first_name       = optional(string)
    last_name        = optional(string)
    attributes       = optional(map(list(string)))
    required_actions = optional(list(string))
    initial_password = optional(object({
      value     = string
      temporary = optional(bool)
    }))
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

variable "role_bindings" {
  description = "Role bindings to users and groups."
  type = list(object({
    realm        = string
    user_id      = optional(string)
    username     = optional(string)
    group_id     = optional(string)
    group_name   = optional(string)
    realm_roles  = optional(list(string))
    client_roles = optional(map(list(string)))
  }))
  default = []
}
