variable "realms" {
  description = "Map of realms keyed by name."
  type = map(object({
    id    = string
    realm = string
  }))
}

variable "identity_providers" {
  description = "List of identity providers (OIDC/SAML) to configure for this Keycloak instance."
  type = list(object({
    name               = string
    realm              = optional(string)
    provider_type      = string
    enabled            = optional(bool)
    alias              = optional(string)
    display_name       = optional(string)
    trust_email        = optional(bool)
    store_token        = optional(bool)
    link_only          = optional(bool)
    hide_on_login_page = optional(bool)

    client_id         = optional(string)
    client_secret     = optional(string)
    authorization_url = optional(string)
    token_url         = optional(string)
    userinfo_url      = optional(string)
    issuer            = optional(string)
    jwks_url          = optional(string)
    default_scopes    = optional(list(string))

    single_sign_on_service_url = optional(string)
    single_logout_service_url  = optional(string)
    entity_id                  = optional(string)
    x509_certificate           = optional(string)
    name_id_policy_format      = optional(string)
    force_authn                = optional(bool)
  }))
  default   = []
  sensitive = true
}

variable "identity_provider_mappers" {
  description = "List of identity provider mappers to map external attributes/claims into Keycloak."
  type = list(object({
    identity_provider_alias = string
    realm                   = optional(string)
    name                    = string
    mapper_type             = string
    config                  = optional(map(string))
  }))
  default = []
}

variable "ldap_user_federations" {
  description = "LDAP user federation providers per realm."
  type = list(object({
    realm                   = string
    name                    = string
    enabled                 = optional(bool)
    priority                = optional(number)
    edit_mode               = optional(string)
    import_enabled          = optional(bool)
    sync_registrations      = optional(bool)
    vendor                  = optional(string)
    username_ldap_attribute = optional(string)
    rdn_ldap_attribute      = optional(string)
    uuid_ldap_attribute     = optional(string)
    user_object_classes     = optional(list(string))
    connection_url          = string
    users_dn                = string
    bind_dn                 = optional(string)
    bind_credential         = optional(string)
    use_truststore_spi      = optional(string)
    trust_email             = optional(bool)
    pagination              = optional(bool)
    start_tls               = optional(bool)
  }))
  default   = []
  sensitive = true
}

variable "kerberos_user_federations" {
  description = "Kerberos user federation providers per realm."
  type = list(object({
    realm                      = string
    name                       = string
    enabled                    = optional(bool)
    priority                   = optional(number)
    kerberos_realm             = string
    server_principal           = string
    key_tab                    = string
    debug                      = optional(bool)
    allow_password_auth        = optional(bool)
    allow_kerberos_auth        = optional(bool)
    update_profile_first_login = optional(bool)
  }))
  default = []
}
