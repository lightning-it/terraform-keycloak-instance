terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
  }
}

module "realms" {
  source = "./modules/realms"

  realms                = var.realms
  auth_flow_settings    = var.auth_flow_settings
  password_policies     = var.password_policies
  bruteforce_settings   = var.bruteforce_settings
  otp_settings          = var.otp_settings
  theme_settings        = var.theme_settings
  localization_settings = var.localization_settings
  event_settings        = var.event_settings
  session_settings      = var.session_settings
  token_settings        = var.token_settings
  smtp_settings         = var.smtp_settings
}

module "clients" {
  source = "./modules/clients"

  realms        = module.realms.realms
  clients       = var.clients
  client_scopes = var.client_scopes
}

module "roles" {
  source = "./modules/roles"

  realms       = module.realms.realms
  clients      = module.clients.clients
  realm_roles  = var.realm_roles
  client_roles = var.client_roles
}

module "groups_users" {
  source = "./modules/groups_users"

  realms           = module.realms.realms
  clients          = module.clients.clients
  realm_roles      = module.roles.realm_roles
  client_roles     = module.roles.client_roles
  groups           = var.groups
  default_groups   = var.default_groups
  users            = var.users
  service_accounts = var.service_accounts
  role_bindings    = var.role_bindings
}

module "idps_federation" {
  source = "./modules/idps_federation"

  realms                    = module.realms.realms
  identity_providers        = var.identity_providers
  identity_provider_mappers = var.identity_provider_mappers
  ldap_user_federations     = var.ldap_user_federations
  kerberos_user_federations = var.kerberos_user_federations
}
