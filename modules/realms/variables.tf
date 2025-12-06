variable "realms" {
  description = "List of Keycloak realms to manage with this module."
  type = list(object({
    name                           = string
    display_name                   = optional(string)
    enabled                        = optional(bool)
    login_theme                    = optional(string)
    account_theme                  = optional(string)
    admin_theme                    = optional(string)
    email_theme                    = optional(string)
    registration_allowed           = optional(bool)
    remember_me                    = optional(bool)
    login_with_email_allowed       = optional(bool)
    duplicate_emails_allowed       = optional(bool)
    reset_password_allowed         = optional(bool)
    verify_email                   = optional(bool)
    registration_email_as_username = optional(bool)
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
