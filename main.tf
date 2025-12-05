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
  # Convert the list of realms into a map for stable for_each usage
  realms = {
    for r in var.realms :
    r.name => r
  }

  default_realm = try(var.realms[0].name, null)

  client_scopes = {
    for s in var.client_scopes :
    s.name => merge(s, {
      realm    = coalesce(try(s.realm, null), local.default_realm)
      protocol = coalesce(try(s.protocol, null), "openid-connect")
    })
  }

  client_scope_mappers = flatten([
    for scope_name, scope in local.client_scopes : [
      for mapper in coalesce(try(scope.mappers, null), []) : {
        scope_name = scope_name
        realm      = scope.realm
        name       = mapper.name
        mapper     = mapper
      }
    ]
  ])
  client_scope_mappers_map = {
    for m in local.client_scope_mappers :
    "${m.scope_name}:${m.name}" => m
  }

  clients = {
    for c in var.clients :
    c.client_id => merge(c, {
      realm = coalesce(try(c.realm, null), local.default_realm)
    })
  }

  clients_with_default_scopes = {
    for k, v in local.clients :
    k => v if length(coalesce(try(v.default_scopes, null), [])) > 0
  }

  clients_with_optional_scopes = {
    for k, v in local.clients :
    k => v if length(coalesce(try(v.optional_scopes, null), [])) > 0
  }
}

resource "keycloak_realm" "this" {
  for_each = local.realms

  # Technical realm name
  realm = each.value.name

  # Optional fields with sane defaults
  enabled                  = coalesce(try(each.value.enabled, null), true)
  display_name             = try(each.value.display_name, null)
  login_theme              = try(each.value.login_theme, null)
  registration_allowed     = coalesce(try(each.value.registration_allowed, null), false)
  remember_me              = coalesce(try(each.value.remember_me, null), true)
  login_with_email_allowed = coalesce(try(each.value.login_with_email_allowed, null), true)
}

resource "keycloak_openid_client_scope" "this" {
  for_each = local.client_scopes

  realm_id    = each.value.realm
  name        = each.value.name
  description = try(each.value.description, null)
  protocol    = each.value.protocol
}

resource "keycloak_generic_protocol_mapper" "client_scope" {
  for_each = local.client_scope_mappers_map

  realm_id        = each.value.realm
  client_scope_id = keycloak_openid_client_scope.this[each.value.scope_name].id
  name            = each.value.name
  protocol        = coalesce(try(each.value.mapper.protocol, null), "openid-connect")
  protocol_mapper = each.value.mapper.protocol_mapper

  consent_required = coalesce(try(each.value.mapper.consent_required, null), false)
  consent_text     = try(each.value.mapper.consent_text, null)
  config           = coalesce(try(each.value.mapper.config, null), {})
}

resource "keycloak_openid_client" "this" {
  for_each = local.clients

  realm_id    = each.value.realm
  client_id   = each.value.client_id
  name        = try(each.value.name, null)
  access_type = upper(each.value.client_type)
  base_url    = try(each.value.base_url, null)

  redirect_uris = coalesce(try(each.value.redirect_uris, null), [])
  web_origins   = coalesce(try(each.value.web_origins, null), [])

  standard_flow_enabled        = coalesce(try(each.value.standard_flow_enabled, null), true)
  implicit_flow_enabled        = coalesce(try(each.value.implicit_flow_enabled, null), false)
  direct_access_grants_enabled = coalesce(try(each.value.direct_access_grants_enabled, null), true)
  service_accounts_enabled     = coalesce(try(each.value.service_accounts_enabled, null), false)
  frontchannel_logout_enabled  = coalesce(try(each.value.frontchannel_logout_enabled, null), true)
}

resource "keycloak_openid_client_default_scopes" "this" {
  for_each = local.clients_with_default_scopes

  realm_id  = each.value.realm
  client_id = keycloak_openid_client.this[each.key].id

  default_scopes = coalesce(try(each.value.default_scopes, null), [])
}

resource "keycloak_openid_client_optional_scopes" "this" {
  for_each = local.clients_with_optional_scopes

  realm_id  = each.value.realm
  client_id = keycloak_openid_client.this[each.key].id

  optional_scopes = coalesce(try(each.value.optional_scopes, null), [])
}
