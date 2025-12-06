variable "realms" {
  description = "List of Keycloak realms to manage with this module."
  type = list(object({
    # Required
    name = string

    # Optional fields — handled with try()/coalesce() in main.tf
    display_name             = optional(string)
    enabled                  = optional(bool)
    login_theme              = optional(string)
    registration_allowed     = optional(bool)
    remember_me              = optional(bool)
    login_with_email_allowed = optional(bool)
  }))

  default = []
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
