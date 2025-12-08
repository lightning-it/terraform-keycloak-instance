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

  normalized_role_bindings = [
    for rb in var.role_bindings :
    merge(rb, {
      realm        = rb.realm
      realm_roles  = coalesce(try(rb.realm_roles, null), [])
      client_roles = coalesce(try(rb.client_roles, null), {})
    })
  ]

  normalized_user_role_bindings = [
    for rb in local.normalized_role_bindings :
    rb if try(rb.user_id, null) != null || try(rb.username, null) != null
  ]

  normalized_group_role_bindings = [
    for rb in local.normalized_role_bindings :
    rb if try(rb.group_id, null) != null || try(rb.group_name, null) != null
  ]
}

locals {
  normalized_groups = {
    for g in var.groups :
    "${coalesce(try(g.realm, null), local.default_realm)}/${g.name}" => merge(g, {
      realm      = coalesce(try(g.realm, null), local.default_realm)
      attributes = coalesce(try(g.attributes, null), {})
      parent     = try(g.parent, null)
      path       = try(g.path, null)
    })
    if coalesce(try(g.realm, null), local.default_realm) != null
  }

  realms_for_groups = distinct([for g in local.normalized_groups : g.realm])

  default_groups_input = {
    for dg in var.default_groups :
    dg.realm => dg.names
  }

  default_groups_resolved = {
    for realm in local.realms_for_groups :
    realm => compact([
      for name in coalesce(try(local.default_groups_input[realm], null), []) :
      try(keycloak_group.this["${realm}/${name}"].id, null)
    ])
    if length(coalesce(try(local.default_groups_input[realm], null), [])) > 0
  }
}

locals {
  normalized_users = {
    for u in var.users :
    "${coalesce(try(u.realm, null), local.default_realm)}/${u.username}" => merge(u, {
      realm      = coalesce(try(u.realm, null), local.default_realm)
      enabled    = coalesce(try(u.enabled, null), true)
      attributes = coalesce(try(u.attributes, null), {})
    })
    if coalesce(try(u.realm, null), local.default_realm) != null
  }

  user_lookup = {
    for rb in local.normalized_user_role_bindings :
    "${rb.realm}:${rb.username}" => {
      realm    = rb.realm
      username = rb.username
    } if try(rb.username, null) != null && !contains(keys(local.normalized_users), "${rb.realm}/${rb.username}")
  }

  group_lookup = {
    for rb in local.normalized_group_role_bindings :
    "${rb.realm}:${rb.group_name}" => {
      realm = rb.realm
      name  = rb.group_name
    } if try(rb.group_name, null) != null && !contains(keys(local.normalized_groups), "${rb.realm}/${rb.group_name}")
  }
}

locals {
  normalized_service_accounts = {
    for sa in var.service_accounts :
    "${coalesce(try(sa.realm, null), try(var.clients[sa.client_id].realm, null), local.default_realm)}/${sa.client_id}" => merge(sa, {
      realm      = coalesce(try(sa.realm, null), try(var.clients[sa.client_id].realm, null), local.default_realm)
      enabled    = coalesce(try(sa.enabled, null), true)
      attributes = coalesce(try(sa.attributes, null), {})
    })
    if coalesce(try(sa.realm, null), try(var.clients[sa.client_id].realm, null), local.default_realm) != null
  }
}

data "keycloak_user" "by_username" {
  for_each = local.user_lookup

  realm_id = var.realms[each.value.realm].id
  username = each.value.username
}

data "keycloak_group" "by_name" {
  for_each = local.group_lookup

  realm_id = var.realms[each.value.realm].id
  name     = each.value.name
}

resource "keycloak_group" "this" {
  for_each = local.normalized_groups

  realm_id = var.realms[each.value.realm].id
  name     = each.value.name
  attributes = {
    for k, v in each.value.attributes :
    k => join(",", v)
  }
  parent_id = null
}

resource "keycloak_default_groups" "this" {
  for_each = local.default_groups_resolved

  realm_id  = var.realms[each.key].id
  group_ids = each.value
}

resource "keycloak_user" "this" {
  for_each = local.normalized_users

  realm_id   = var.realms[each.value.realm].id
  username   = each.value.username
  enabled    = each.value.enabled
  email      = try(each.value.email, null)
  first_name = try(each.value.first_name, null)
  last_name  = try(each.value.last_name, null)
  attributes = {
    for k, v in each.value.attributes :
    k => join(",", v)
  }
  required_actions = coalesce(try(each.value.required_actions, null), [])

  dynamic "initial_password" {
    for_each = try(each.value.initial_password, null) != null ? [each.value.initial_password] : []
    content {
      value     = tostring(initial_password.value)
      temporary = coalesce(try(initial_password.temporary, null), true)
    }
  }
}

resource "keycloak_user_roles" "this" {
  for_each = {
    for idx, rb in local.normalized_user_role_bindings :
    "${rb.realm}:${coalesce(try(rb.user_id, null), try(rb.username, null), idx)}" => rb
  }

  realm_id = var.realms[each.value.realm].id
  user_id = coalesce(
    try(each.value.user_id, null),
    try(keycloak_user.this["${each.value.realm}/${each.value.username}"].id, null),
    try(data.keycloak_user.by_username["${each.value.realm}:${each.value.username}"].id, null),
    ""
  )

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(var.realm_roles["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(var.client_roles["${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}

resource "keycloak_group_roles" "this" {
  for_each = {
    for idx, rb in local.normalized_group_role_bindings :
    "${rb.realm}:${coalesce(try(rb.group_id, null), try(rb.group_name, null), idx)}" => rb
  }

  realm_id = var.realms[each.value.realm].id
  group_id = coalesce(
    try(each.value.group_id, null),
    try(keycloak_group.this["${each.value.realm}/${each.value.group_name}"].id, null),
    try(data.keycloak_group.by_name["${each.value.realm}:${each.value.group_name}"].id, null),
    ""
  )

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(var.realm_roles["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(var.client_roles["${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}

resource "keycloak_user_roles" "service_accounts" {
  for_each = {
    for key, sa in local.normalized_service_accounts :
    key => sa
  }

  realm_id = var.realms[each.value.realm].id
  user_id  = var.clients[each.value.client_id].service_account_user_id

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(var.realm_roles["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(var.client_roles["${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}
