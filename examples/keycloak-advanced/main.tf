terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5"
    }
  }
}

provider "keycloak" {
  url   = "https://keycloak.example.com"
  realm = "master"

  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

module "keycloak_instance" {
  source  = "../.."
  version = ">= 1.0.0"

  realms = [
    {
      name         = "demo-advanced"
      display_name = "Demo Advanced"
      enabled      = true
      login_theme  = "keycloak"
    }
  ]

  client_scopes = [
    {
      name        = "custom-api"
      realm       = "demo-advanced"
      description = "Custom API scope"
      protocol    = "openid-connect"
      mappers = [
        {
          name            = "department-claim"
          protocol        = "openid-connect"
          protocol_mapper = "oidc-usermodel-attribute-mapper"
          config = {
            "user.attribute" = "department"
            "claim.name"     = "department"
            "jsonType.label" = "String"
          }
        }
      ]
    }
  ]

  clients = [
    {
      client_id                    = "backend-api"
      client_type                  = "confidential"
      realm                        = "demo-advanced"
      name                         = "Backend API"
      redirect_uris                = ["https://backend.example.com/*"]
      web_origins                  = ["https://backend.example.com"]
      base_url                     = "https://backend.example.com"
      standard_flow_enabled        = true
      implicit_flow_enabled        = false
      direct_access_grants_enabled = true
      service_accounts_enabled     = true
      default_scopes               = ["profile", "email", "custom-api"]
      optional_scopes              = ["address"]
    },
    {
      client_id   = "frontend-app"
      client_type = "public"
      realm       = "demo-advanced"
      name        = "Frontend App"
      redirect_uris = [
        "https://frontend.example.com/*"
      ]
      base_url = "https://frontend.example.com"
    }
  ]

  realm_roles = [
    {
      name        = "platform-admin"
      realm       = "demo-advanced"
      description = "Platform administrator"
    }
  ]

  client_roles = [
    {
      client_id   = "backend-api"
      realm       = "demo-advanced"
      name        = "api-admin"
      description = "Admin access to backend API"
    }
  ]

  groups = [
    {
      name  = "admins"
      realm = "demo-advanced"
      attributes = {
        team = ["platform"]
      }
    }
  ]

  default_groups = [
    {
      realm = "demo-advanced"
      names = ["admins"]
    }
  ]

  service_accounts = [
    {
      client_id    = "backend-api"
      realm        = "demo-advanced"
      enabled      = true
      realm_roles  = ["platform-admin"]
      client_roles = { backend-api = ["api-admin"] }
    }
  ]

  identity_providers = [
    {
      name               = "google"
      alias              = "google"
      realm              = "demo-advanced"
      provider_type      = "oidc"
      enabled            = true
      client_id          = "google-client-id"
      client_secret      = "google-client-secret"
      authorization_url  = "https://accounts.google.com/o/oauth2/v2/auth"
      token_url          = "https://oauth2.googleapis.com/token"
      userinfo_url       = "https://openidconnect.googleapis.com/v1/userinfo"
      issuer             = "https://accounts.google.com"
      default_scopes     = ["openid", "email", "profile"]
      trust_email        = true
      hide_on_login_page = false
    },
    {
      name                       = "saml-demo"
      alias                      = "saml-demo"
      realm                      = "demo-advanced"
      provider_type              = "saml"
      enabled                    = true
      display_name               = "SAML Demo"
      single_sign_on_service_url = "https://sso.example.com/saml"
      single_logout_service_url  = "https://sso.example.com/logout"
      entity_id                  = "https://sso.example.com/entity"
      x509_certificate           = "MIICdzCCAhCgAwIBAgIJAI0fakecerttest"
      name_id_policy_format      = "Email"
      hide_on_login_page         = false
      trust_email                = false
      force_authn                = false
    }
  ]

  smtp_settings = [
    {
      realm        = "demo-advanced"
      host         = "smtp.example.com"
      port         = 587
      from         = "no-reply@example.com"
      auth         = true
      user         = "smtp-user"
      password     = "smtp-pass"
      starttls     = true
      from_display = "Example SMTP"
    }
  ]

  password_policies = [
    {
      realm    = "demo-advanced"
      policies = ["length(12)", "digits(1)", "lowerCase(1)", "upperCase(1)", "specialChars(1)"]
    }
  ]

  bruteforce_settings = [
    {
      realm                            = "demo-advanced"
      enabled                          = true
      permanent_lockout                = false
      max_login_failures               = 5
      wait_increment_seconds           = 60
      quick_login_check_milli          = 1000
      minimum_quick_login_wait_seconds = 30
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 3600
    }
  ]

  auth_flow_settings = [
    {
      realm                          = "demo-advanced"
      login_with_email_allowed       = true
      duplicate_emails_allowed       = false
      reset_password_allowed         = true
      remember_me                    = true
      verify_email                   = true
      registration_allowed           = false
      registration_email_as_username = false
    }
  ]

  otp_settings = [
    {
      realm                 = "demo-advanced"
      otp_type              = "totp"
      otp_alg               = "HmacSHA1"
      otp_digits            = 6
      otp_initial_counter   = 0
      otp_look_ahead_window = 1
      otp_period            = 30
    }
  ]

  localization_settings = [
    {
      realm                        = "demo-advanced"
      internationalization_enabled = true
      supported_locales            = ["en", "de"]
      default_locale               = "en"
    }
  ]

  custom_theme_hooks = [
    {
      name        = "keycloak"
      realm       = "demo-advanced"
      source_path = "themes/keycloak"
      notes       = "Using built-in theme reference."
    }
  ]

  event_settings = [
    {
      realm                        = "demo-advanced"
      events_enabled               = true
      events_expiration            = 3600
      events_listeners             = ["jboss-logging"]
      enabled_event_types          = ["LOGIN", "LOGOUT", "REGISTER"]
      admin_events_enabled         = true
      admin_events_details_enabled = true
    }
  ]

  ldap_user_federations = [
    {
      realm                   = "demo-advanced"
      name                    = "corp-ldap"
      enabled                 = true
      priority                = 0
      vendor                  = "AD"
      connection_url          = "ldap://ldap.example.com:389"
      users_dn                = "ou=Users,dc=example,dc=com"
      bind_dn                 = "cn=bind,dc=example,dc=com"
      bind_credential         = "secret"
      username_ldap_attribute = "sAMAccountName"
      rdn_ldap_attribute      = "cn"
      uuid_ldap_attribute     = "objectGUID"
      user_object_classes     = ["person", "organizationalPerson", "user"]
      import_enabled          = true
      sync_registrations      = false
      trust_email             = true
      pagination              = true
      start_tls               = false
    }
  ]

  kerberos_user_federations = [
    {
      realm                      = "demo-advanced"
      name                       = "corp-kerberos"
      enabled                    = true
      priority                   = 1
      kerberos_realm             = "EXAMPLE.COM"
      server_principal           = "HTTP/keycloak.example.com@EXAMPLE.COM"
      key_tab                    = "/etc/keytabs/keycloak.keytab"
      allow_password_auth        = false
      allow_kerberos_auth        = true
      update_profile_first_login = true
    }
  ]
}
