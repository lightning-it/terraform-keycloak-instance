terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
  }
}

locals {
  default_realm = try(keys(var.realms)[0], null)

  normalized_identity_providers = {
    for idp in nonsensitive(var.identity_providers) :
    "${coalesce(try(idp.realm, null), local.default_realm)}/${coalesce(try(idp.alias, null), idp.name)}" => merge(idp, {
      realm         = coalesce(try(idp.realm, null), local.default_realm)
      alias         = coalesce(try(idp.alias, null), idp.name)
      enabled       = coalesce(try(idp.enabled, null), true)
      provider_type = lower(idp.provider_type)
    })
    if coalesce(try(idp.realm, null), local.default_realm) != null
  }

  normalized_oidc_identity_providers = {
    for k, v in local.normalized_identity_providers :
    k => v if v.provider_type == "oidc"
  }

  normalized_saml_identity_providers = {
    for k, v in local.normalized_identity_providers :
    k => v if v.provider_type == "saml"
  }

  normalized_identity_provider_mappers = {
    for m in var.identity_provider_mappers :
    "${coalesce(try(m.realm, null), local.default_realm)}/${m.identity_provider_alias}/${m.name}" => merge(m, {
      realm  = coalesce(try(m.realm, null), local.default_realm)
      config = coalesce(try(m.config, null), {})
    })
    if coalesce(try(m.realm, null), local.default_realm) != null
  }

  normalized_ldap_user_federations = {
    for f in nonsensitive(var.ldap_user_federations) :
    "${f.realm}/${f.name}" => f
  }

  normalized_kerberos_user_federations = {
    for f in var.kerberos_user_federations :
    "${f.realm}/${f.name}" => f
  }
}

resource "keycloak_oidc_identity_provider" "this" {
  for_each = local.normalized_oidc_identity_providers

  realm              = var.realms[each.value.realm].realm
  alias              = each.value.alias
  enabled            = each.value.enabled
  display_name       = try(each.value.display_name, null)
  trust_email        = coalesce(try(each.value.trust_email, null), false)
  store_token        = coalesce(try(each.value.store_token, null), false)
  link_only          = coalesce(try(each.value.link_only, null), false)
  hide_on_login_page = coalesce(try(each.value.hide_on_login_page, null), false)

  client_id     = try(each.value.client_id, null)
  client_secret = try(each.value.client_secret, null)

  authorization_url = try(each.value.authorization_url, null)
  token_url         = try(each.value.token_url, null)
  user_info_url     = try(each.value.userinfo_url, null)
  issuer            = try(each.value.issuer, null)
  jwks_url          = try(each.value.jwks_url, null)
  default_scopes    = try(join(" ", coalesce(try(each.value.default_scopes, null), [])), null)
}

resource "keycloak_saml_identity_provider" "this" {
  for_each = local.normalized_saml_identity_providers

  realm              = var.realms[each.value.realm].realm
  alias              = each.value.alias
  enabled            = each.value.enabled
  display_name       = try(each.value.display_name, null)
  trust_email        = coalesce(try(each.value.trust_email, null), false)
  store_token        = coalesce(try(each.value.store_token, null), false)
  link_only          = coalesce(try(each.value.link_only, null), false)
  hide_on_login_page = coalesce(try(each.value.hide_on_login_page, null), false)

  entity_id                  = try(each.value.entity_id, null)
  single_sign_on_service_url = try(each.value.single_sign_on_service_url, null)
  single_logout_service_url  = try(each.value.single_logout_service_url, null)
  name_id_policy_format      = try(each.value.name_id_policy_format, null)
  force_authn                = coalesce(try(each.value.force_authn, null), false)
  signing_certificate        = try(each.value.x509_certificate, null)
}

resource "keycloak_custom_identity_provider_mapper" "this" {
  for_each = local.normalized_identity_provider_mappers

  realm                    = var.realms[each.value.realm].realm
  name                     = each.value.name
  identity_provider_alias  = each.value.identity_provider_alias
  identity_provider_mapper = each.value.mapper_type
  extra_config             = each.value.config
}

resource "keycloak_ldap_user_federation" "this" {
  for_each = local.normalized_ldap_user_federations

  realm_id                = var.realms[each.value.realm].id
  name                    = each.value.name
  enabled                 = coalesce(try(each.value.enabled, null), true)
  priority                = try(each.value.priority, null)
  edit_mode               = try(each.value.edit_mode, null)
  import_enabled          = try(each.value.import_enabled, null)
  sync_registrations      = try(each.value.sync_registrations, null)
  vendor                  = try(each.value.vendor, null)
  username_ldap_attribute = try(each.value.username_ldap_attribute, null)
  rdn_ldap_attribute      = try(each.value.rdn_ldap_attribute, null)
  uuid_ldap_attribute     = try(each.value.uuid_ldap_attribute, null)
  user_object_classes     = try(each.value.user_object_classes, null)
  connection_url          = each.value.connection_url
  users_dn                = each.value.users_dn
  bind_dn                 = try(each.value.bind_dn, null)
  bind_credential         = try(each.value.bind_credential, null)
  use_truststore_spi      = try(each.value.use_truststore_spi, null)
  trust_email             = try(each.value.trust_email, null)
  pagination              = try(each.value.pagination, null)
  start_tls               = try(each.value.start_tls, null)
}

resource "keycloak_custom_user_federation" "kerberos" {
  for_each = local.normalized_kerberos_user_federations

  realm_id    = var.realms[each.value.realm].id
  name        = each.value.name
  provider_id = "kerberos"
  enabled     = coalesce(try(each.value.enabled, null), true)
  priority    = try(each.value.priority, null)

  config = {
    for k, v in {
      kerberosRealm               = each.value.kerberos_realm
      serverPrincipal             = each.value.server_principal
      keyTab                      = each.value.key_tab
      debug                       = try(each.value.debug, null)
      allowPasswordAuthentication = try(each.value.allow_password_auth, null)
      allowKerberosAuthentication = try(each.value.allow_kerberos_auth, null)
      updateProfileFirstLogin     = try(each.value.update_profile_first_login, null)
    } : k => tostring(v) if v != null
  }
}
