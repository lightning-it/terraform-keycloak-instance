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

  validation {
    condition = alltrue([
      for c in var.clients :
      contains(["public", "confidential", "bearer-only"], c.client_type)
    ])
    error_message = "clients[*].client_type must be one of \"public\", \"confidential\", or \"bearer-only\"."
  }
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

    # OIDC-specific
    client_id         = optional(string)
    client_secret     = optional(string)
    authorization_url = optional(string)
    token_url         = optional(string)
    userinfo_url      = optional(string)
    issuer            = optional(string)
    jwks_url          = optional(string)
    default_scopes    = optional(list(string))

    # SAML-specific
    single_sign_on_service_url = optional(string)
    single_logout_service_url  = optional(string)
    entity_id                  = optional(string)
    x509_certificate           = optional(string)
    name_id_policy_format      = optional(string)
    force_authn                = optional(bool)
  }))

  default   = []
  sensitive = true

  validation {
    condition = alltrue([
      for idp in var.identity_providers :
      contains(["oidc", "saml"], idp.provider_type)
    ])
    error_message = "identity_providers[*].provider_type must be either \"oidc\" or \"saml\"."
  }
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

variable "smtp_settings" {
  description = "SMTP settings per realm for outgoing email."
  type = list(object({
    realm        = string
    host         = string
    port         = number
    from         = string
    auth         = bool
    user         = optional(string)
    password     = optional(string)
    ssl          = optional(bool)
    starttls     = optional(bool)
    reply_to     = optional(string)
    from_display = optional(string)
  }))

  default   = []
  sensitive = true
}

variable "password_policies" {
  description = "Password policies per realm."
  type = list(object({
    realm    = string
    policies = list(string)
  }))

  default = []
}

variable "bruteforce_settings" {
  description = "Brute-force protection settings per realm."
  type = list(object({
    realm                            = string
    enabled                          = bool
    permanent_lockout                = bool
    max_login_failures               = number
    wait_increment_seconds           = number
    quick_login_check_milli          = number
    minimum_quick_login_wait_seconds = number
    max_failure_wait_seconds         = number
    failure_reset_time_seconds       = number
  }))

  default = []
}

variable "auth_flow_settings" {
  description = "Authentication flow and login UX settings per realm."
  type = list(object({
    realm                          = string
    login_with_email_allowed       = optional(bool)
    duplicate_emails_allowed       = optional(bool)
    reset_password_allowed         = optional(bool)
    remember_me                    = optional(bool)
    verify_email                   = optional(bool)
    registration_allowed           = optional(bool)
    registration_email_as_username = optional(bool)
  }))

  default = []
}

variable "otp_settings" {
  description = "OTP/MFA configuration per realm."
  type = list(object({
    realm                 = string
    otp_type              = optional(string)
    otp_alg               = optional(string)
    otp_digits            = optional(number)
    otp_initial_counter   = optional(number)
    otp_look_ahead_window = optional(number)
    otp_period            = optional(number)
  }))

  default = []
}

variable "theme_settings" {
  description = "Theme settings per realm (login, account, admin, email)."
  type = list(object({
    realm         = string
    login_theme   = optional(string)
    account_theme = optional(string)
    admin_theme   = optional(string)
    email_theme   = optional(string)
  }))

  default = []
}

variable "localization_settings" {
  description = "Localization settings per realm (internationalization and locales)."
  type = list(object({
    realm                        = string
    internationalization_enabled = optional(bool)
    supported_locales            = optional(list(string))
    default_locale               = optional(string)
  }))

  default = []
}

variable "custom_theme_hooks" {
  description = "Optional hooks or metadata describing custom theme deployments."
  type = list(object({
    name        = string
    realm       = optional(string)
    source_path = optional(string)
    notes       = optional(string)
  }))

  default = []
}

variable "event_settings" {
  description = "Event configuration per realm (enabled events, storage, listeners)."
  type = list(object({
    realm                        = string
    events_enabled               = optional(bool)
    events_expiration            = optional(number)
    events_listeners             = optional(list(string))
    enabled_event_types          = optional(list(string))
    admin_events_enabled         = optional(bool)
    admin_events_details_enabled = optional(bool)
  }))

  default = []
}

variable "event_listener_hooks" {
  description = "Optional metadata for custom event listener deployments."
  type = list(object({
    name       = string
    realm      = optional(string)
    target_url = optional(string)
    notes      = optional(string)
  }))

  default = []
}

variable "session_settings" {
  description = "Session timeout settings per realm."
  type = list(object({
    realm                                = string
    sso_session_idle_timeout             = optional(number)
    sso_session_max_lifespan             = optional(number)
    sso_session_idle_timeout_remember_me = optional(number)
    sso_session_max_lifespan_remember_me = optional(number)
    offline_session_idle_timeout         = optional(number)
    offline_session_max_lifespan         = optional(number)
  }))

  default = []
}

variable "token_settings" {
  description = "Token and login timeout settings per realm."
  type = list(object({
    realm                                   = string
    login_timeout                           = optional(number)
    login_action_timeout                    = optional(number)
    access_token_lifespan                   = optional(number)
    access_token_lifespan_for_implicit_flow = optional(number)
    client_session_idle_timeout             = optional(number)
    client_session_max_lifespan             = optional(number)
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

  validation {
    condition = alltrue([
      for f in var.ldap_user_federations :
      f.vendor == null || contains(["ad", "rhds", "other"], lower(f.vendor))
    ])
    error_message = "ldap_user_federations[*].vendor must be one of \"ad\", \"rhds\" or \"other\" when set."
  }
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
