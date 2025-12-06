output "realms" {
  description = "Map of managed realms, keyed by realm name."
  value       = module.realms.realms
}

output "clients" {
  description = "Map of configured clients keyed by client_id."
  value       = module.clients.clients
}

output "client_scopes" {
  description = "Map of configured client scopes keyed by scope name."
  value       = module.clients.client_scopes
}

output "realm_roles" {
  description = "Map of configured realm roles keyed by \"<realm>:<role_name>\"."
  value       = module.roles.realm_roles
}

output "client_roles" {
  description = "Map of configured client roles keyed by \"<client_id>:<role_name>\"."
  value       = module.roles.client_roles
}

output "role_bindings" {
  description = "Applied role bindings for users and groups."
  value       = module.groups_users.role_bindings
}

output "groups" {
  description = "Map of configured groups keyed by \"<realm>/<name>\"."
  value       = module.groups_users.groups
}

output "default_groups" {
  description = "Default groups configured per realm."
  value       = module.groups_users.default_groups
}

output "users" {
  description = "Map of seeded users keyed by \"<realm>/<username>\"."
  value       = module.groups_users.users
}

output "custom_theme_hooks" {
  description = "Custom theme hook metadata passed to the module."
  value       = var.custom_theme_hooks
}

output "event_listener_hooks" {
  description = "Event listener hook metadata passed to the module."
  value       = var.event_listener_hooks
}

output "ldap_user_federations" {
  description = "Map of LDAP user federation providers keyed by \"<realm>/<name>\"."
  value       = module.idps_federation.ldap_user_federations
}

output "kerberos_user_federations" {
  description = "Map of Kerberos user federation providers keyed by \"<realm>/<name>\"."
  value       = module.idps_federation.kerberos_user_federations
}

output "service_accounts" {
  description = "Map of client service account users keyed by \"<realm>/<client_id>\"."
  value       = module.groups_users.service_accounts
}

output "identity_providers" {
  description = "Map of configured identity providers keyed by \"<realm>/<alias>\"."
  value       = module.idps_federation.identity_providers
}

output "identity_provider_mappers" {
  description = "Map of identity provider mappers keyed by \"<realm>/<alias>/<name>\"."
  value       = module.idps_federation.identity_provider_mappers
}

output "theme_settings" {
  description = "Effective theme settings per realm."
  value       = module.realms.theme_settings
}

output "localization_settings" {
  description = "Localization settings per realm."
  value       = module.realms.localization_settings
}

output "event_settings" {
  description = "Event configuration per realm."
  value       = module.realms.event_settings
}

output "session_settings" {
  description = "Summary of session timeout settings per realm."
  value       = module.realms.session_settings
}

output "token_settings" {
  description = "Summary of token timeout settings per realm."
  value       = module.realms.token_settings
}
