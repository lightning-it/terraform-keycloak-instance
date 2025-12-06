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
  url   = "http://host.docker.internal:8080"
  realm = "master"

  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

module "keycloak_instance" {
  source = "../.."

  realms = [
    {
      name         = "demo-empty"
      display_name = "Demo Empty"
    }
  ]

  clients                   = []
  client_scopes             = []
  realm_roles               = []
  client_roles              = []
  role_bindings             = []
  groups                    = []
  default_groups            = []
  users                     = []
  service_accounts          = []
  identity_providers        = []
  identity_provider_mappers = []
  smtp_settings             = []
  password_policies         = []
  bruteforce_settings       = []
  auth_flow_settings        = []
  otp_settings              = []
  theme_settings            = []
  localization_settings     = []
  custom_theme_hooks        = []
  event_settings            = []
  event_listener_hooks      = []
  session_settings          = []
  token_settings            = []
  ldap_user_federations     = []
  kerberos_user_federations = []
}
