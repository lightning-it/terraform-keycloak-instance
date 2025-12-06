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

  realm_roles = {
    for r in var.realm_roles :
    "${coalesce(try(r.realm, null), local.default_realm)}:${r.name}" => merge(r, {
      realm      = coalesce(try(r.realm, null), local.default_realm)
      composites = coalesce(try(r.composites, null), [])
    })
    if coalesce(try(r.realm, null), local.default_realm) != null
  }

  client_roles = {
    for r in var.client_roles :
    "${coalesce(try(r.realm, null), try(var.clients[r.client_id].realm, null), local.default_realm)}:${r.client_id}:${r.name}" => merge(r, {
      realm      = coalesce(try(r.realm, null), try(var.clients[r.client_id].realm, null), local.default_realm)
      composites = coalesce(try(r.composites, null), [])
    })
    if coalesce(try(r.realm, null), try(var.clients[r.client_id].realm, null), local.default_realm) != null
  }
}

resource "keycloak_role" "realm" {
  for_each = local.realm_roles

  realm_id    = var.realms[each.value.realm].id
  name        = each.value.name
  description = try(each.value.description, null)

  composite_roles = []
}

resource "keycloak_role" "client" {
  for_each = local.client_roles

  realm_id    = var.realms[each.value.realm].id
  client_id   = var.clients[each.value.client_id].id
  name        = each.value.name
  description = try(each.value.description, null)

  composite_roles = []
}
