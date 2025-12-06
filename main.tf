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
    "${coalesce(try(r.realm, null), try(local.clients[r.client_id].realm, null), local.default_realm)}:${r.client_id}:${r.name}" => merge(r, {
      realm      = coalesce(try(r.realm, null), try(local.clients[r.client_id].realm, null), local.default_realm)
      composites = coalesce(try(r.composites, null), [])
    })
    if coalesce(try(r.realm, null), try(local.clients[r.client_id].realm, null), local.default_realm) != null
  }

  role_bindings = [
    for rb in var.role_bindings :
    merge(rb, {
      realm        = rb.realm
      realm_roles  = coalesce(try(rb.realm_roles, null), [])
      client_roles = coalesce(try(rb.client_roles, null), {})
    })
  ]

  user_role_bindings = [
    for rb in local.role_bindings :
    rb if try(rb.user_id, null) != null || try(rb.username, null) != null
  ]

  group_role_bindings = [
    for rb in local.role_bindings :
    rb if try(rb.group_id, null) != null || try(rb.group_name, null) != null
  ]

  user_lookup = {
    for rb in local.user_role_bindings :
    "${rb.realm}:${rb.username}" => {
      realm    = rb.realm
      username = rb.username
    } if try(rb.username, null) != null
  }

  group_lookup = {
    for rb in local.group_role_bindings :
    "${rb.realm}:${rb.group_name}" => {
      realm = rb.realm
      name  = rb.group_name
    } if try(rb.group_name, null) != null
  }

  groups = {
    for g in var.groups :
    "${coalesce(try(g.realm, null), local.default_realm)}/${g.name}" => merge(g, {
      realm      = coalesce(try(g.realm, null), local.default_realm)
      attributes = coalesce(try(g.attributes, null), {})
      parent     = try(g.parent, null)
      path       = try(g.path, null)
    })
    if coalesce(try(g.realm, null), local.default_realm) != null
  }

  group_parents = {
    for k, g in local.groups :
    k => try(local.groups["${g.realm}/${g.parent}"], null)
    if try(g.parent, null) != null
  }

  realms_for_groups = distinct([for g in local.groups : g.realm])

  default_groups = {
    for dg in var.default_groups :
    dg.realm => dg.names
  }

  default_groups_resolved = {
    for realm in local.realms_for_groups :
    realm => compact([
      for name in coalesce(try(local.default_groups[realm], null), []) :
      try(keycloak_group.this["${realm}/${name}"].id, null)
    ])
    if length(coalesce(try(local.default_groups[realm], null), [])) > 0
  }

  users = {
    for u in var.users :
    "${coalesce(try(u.realm, null), local.default_realm)}/${u.username}" => merge(u, {
      realm      = coalesce(try(u.realm, null), local.default_realm)
      enabled    = coalesce(try(u.enabled, null), true)
      attributes = coalesce(try(u.attributes, null), {})
    })
    if coalesce(try(u.realm, null), local.default_realm) != null
  }

  service_accounts = {
    for sa in var.service_accounts :
    "${coalesce(try(sa.realm, null), try(local.clients[sa.client_id].realm, null), local.default_realm)}/${sa.client_id}" => merge(sa, {
      realm      = coalesce(try(sa.realm, null), try(local.clients[sa.client_id].realm, null), local.default_realm)
      enabled    = coalesce(try(sa.enabled, null), true)
      attributes = coalesce(try(sa.attributes, null), {})
    })
    if coalesce(try(sa.realm, null), try(local.clients[sa.client_id].realm, null), local.default_realm) != null
  }

  identity_providers = {
    for idp in var.identity_providers :
    "${coalesce(try(idp.realm, null), local.default_realm)}/${coalesce(try(idp.alias, null), idp.name)}" => merge(idp, {
      realm         = coalesce(try(idp.realm, null), local.default_realm)
      alias         = coalesce(try(idp.alias, null), idp.name)
      enabled       = coalesce(try(idp.enabled, null), true)
      provider_type = lower(idp.provider_type)
    })
    if coalesce(try(idp.realm, null), local.default_realm) != null
  }

  oidc_identity_providers = {
    for k, v in local.identity_providers :
    k => v if v.provider_type == "oidc"
  }

  saml_identity_providers = {
    for k, v in local.identity_providers :
    k => v if v.provider_type == "saml"
  }

  identity_provider_mappers = {
    for m in var.identity_provider_mappers :
    "${coalesce(try(m.realm, null), local.default_realm)}/${m.identity_provider_alias}/${m.name}" => merge(m, {
      realm  = coalesce(try(m.realm, null), local.default_realm)
      config = coalesce(try(m.config, null), {})
    })
    if coalesce(try(m.realm, null), local.default_realm) != null
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
}

resource "keycloak_generic_protocol_mapper" "client_scope" {
  for_each = local.client_scope_mappers_map

  realm_id        = each.value.realm
  client_scope_id = keycloak_openid_client_scope.this[each.value.scope_name].id
  name            = each.value.name
  protocol        = coalesce(try(each.value.mapper.protocol, null), "openid-connect")
  protocol_mapper = each.value.mapper.protocol_mapper

  config = merge(
    coalesce(try(each.value.mapper.config, null), {}),
    {
      for k, v in {
        consentRequired = try(each.value.mapper.consent_required, null)
        consentText     = try(each.value.mapper.consent_text, null)
      } : k => tostring(v) if v != null
    }
  )
}

resource "keycloak_openid_client" "this" {
  for_each = local.clients

  realm_id    = each.value.realm
  client_id   = each.value.client_id
  name        = try(each.value.name, null)
  access_type = upper(each.value.client_type)
  base_url    = try(each.value.base_url, null)

  valid_redirect_uris = coalesce(try(each.value.redirect_uris, null), [])
  web_origins         = coalesce(try(each.value.web_origins, null), [])

  standard_flow_enabled        = coalesce(try(each.value.standard_flow_enabled, null), true)
  implicit_flow_enabled        = coalesce(try(each.value.implicit_flow_enabled, null), false)
  direct_access_grants_enabled = coalesce(try(each.value.direct_access_grants_enabled, null), true)
  service_accounts_enabled = coalesce(
    try(each.value.service_accounts_enabled, null),
    contains(keys(local.service_accounts), "${each.value.realm}/${each.value.client_id}")
  )
  frontchannel_logout_enabled = coalesce(try(each.value.frontchannel_logout_enabled, null), true)
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

resource "keycloak_role" "realm" {
  for_each = local.realm_roles

  realm_id    = each.value.realm
  name        = each.value.name
  description = try(each.value.description, null)

  composite_roles = compact([
    for role_name in each.value.composites :
    try(keycloak_role.realm["${each.value.realm}:${role_name}"].id, null)
    if role_name != each.value.name
  ])
}

resource "keycloak_role" "client" {
  for_each = local.client_roles

  realm_id    = each.value.realm
  client_id   = keycloak_openid_client.this[each.value.client_id].id
  name        = each.value.name
  description = try(each.value.description, null)

  composite_roles = compact([
    for role_name in each.value.composites :
    try(keycloak_role.client["${each.value.realm}:${each.value.client_id}:${role_name}"].id, null)
    if role_name != each.value.name
  ])
}

data "keycloak_user" "by_username" {
  for_each = local.user_lookup

  realm_id = each.value.realm
  username = each.value.username
}

data "keycloak_group" "by_name" {
  for_each = local.group_lookup

  realm_id = each.value.realm
  name     = each.value.name
}

resource "keycloak_user_roles" "this" {
  for_each = {
    for idx, rb in local.user_role_bindings :
    "${rb.realm}:${coalesce(try(rb.user_id, null), try(rb.username, null), idx)}" => rb
  }

  realm_id = each.value.realm
  user_id = coalesce(
    try(each.value.user_id, null),
    try(data.keycloak_user.by_username["${each.value.realm}:${each.value.username}"].id, null),
    ""
  )

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(keycloak_role.realm["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(keycloak_role.client["${each.value.realm}:${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}

resource "keycloak_group_roles" "this" {
  for_each = {
    for idx, rb in local.group_role_bindings :
    "${rb.realm}:${coalesce(try(rb.group_id, null), try(rb.group_name, null), idx)}" => rb
  }

  realm_id = each.value.realm
  group_id = coalesce(
    try(each.value.group_id, null),
    try(data.keycloak_group.by_name["${each.value.realm}:${each.value.group_name}"].id, null),
    ""
  )

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(keycloak_role.realm["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(keycloak_role.client["${each.value.realm}:${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}

resource "keycloak_group" "this" {
  for_each = local.groups

  realm_id   = each.value.realm
  name       = each.value.name
  attributes = each.value.attributes
  parent_id  = try(keycloak_group.this["${each.value.realm}/${each.value.parent}"].id, null)
}

resource "keycloak_default_groups" "this" {
  for_each = local.default_groups_resolved

  realm_id  = each.key
  group_ids = each.value
}

resource "keycloak_user" "this" {
  for_each = local.users

  realm_id         = each.value.realm
  username         = each.value.username
  enabled          = each.value.enabled
  email            = try(each.value.email, null)
  first_name       = try(each.value.first_name, null)
  last_name        = try(each.value.last_name, null)
  attributes       = each.value.attributes
  required_actions = coalesce(try(each.value.required_actions, null), [])

  dynamic "initial_password" {
    for_each = try(each.value.initial_password, null) != null ? [each.value.initial_password] : []
    content {
      value     = initial_password.value
      temporary = coalesce(try(initial_password.temporary, null), true)
    }
  }
}

resource "keycloak_user_roles" "service_accounts" {
  for_each = {
    for key, sa in local.service_accounts :
    key => sa
  }

  realm_id = each.value.realm
  user_id  = keycloak_openid_client.this[each.value.client_id].service_account_user_id

  role_ids = compact(concat(
    [
      for role_name in coalesce(try(each.value.realm_roles, null), []) :
      try(keycloak_role.realm["${each.value.realm}:${role_name}"].id, null)
    ],
    flatten([
      for client_id, roles in coalesce(try(each.value.client_roles, null), {}) :
      [
        for role_name in roles :
        try(keycloak_role.client["${each.value.realm}:${client_id}:${role_name}"].id, null)
      ]
    ])
  ))
}

resource "keycloak_oidc_identity_provider" "this" {
  for_each = local.oidc_identity_providers

  realm              = each.value.realm
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
  default_scopes    = coalesce(try(each.value.default_scopes, null), [])
}

resource "keycloak_saml_identity_provider" "this" {
  for_each = local.saml_identity_providers

  realm              = each.value.realm
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
  for_each = local.identity_provider_mappers

  realm                    = each.value.realm
  name                     = each.value.name
  identity_provider_alias  = each.value.identity_provider_alias
  identity_provider_mapper = each.value.mapper_type
  extra_config             = each.value.config
}
