output "realms" {
  description = "Map of managed realms, keyed by realm name."
  value = {
    for name, r in keycloak_realm.this :
    name => {
      id    = r.id
      realm = r.realm
    }
  }
}

output "clients" {
  description = "Map of configured clients keyed by client_id."
  value = {
    for client_id, c in keycloak_openid_client.this :
    client_id => {
      id        = c.id
      realm     = c.realm_id
      client_id = c.client_id
    }
  }
}

output "client_scopes" {
  description = "Map of configured client scopes keyed by scope name."
  value = {
    for name, s in keycloak_openid_client_scope.this :
    name => {
      id       = s.id
      realm    = s.realm_id
      protocol = local.client_scopes[name].protocol
    }
  }
}

output "realm_roles" {
  description = "Map of configured realm roles keyed by \"<realm>:<role_name>\"."
  value = {
    for key, r in keycloak_role.realm :
    key => {
      id    = r.id
      realm = r.realm_id
      name  = r.name
    }
  }
}

output "client_roles" {
  description = "Map of configured client roles keyed by \"<client_id>:<role_name>\"."
  value = {
    for key, r in keycloak_role.client :
    "${local.client_roles[key].client_id}:${local.client_roles[key].name}" => {
      id        = r.id
      realm     = r.realm_id
      client_id = local.client_roles[key].client_id
      name      = local.client_roles[key].name
    }
  }
}

output "role_bindings" {
  description = "Applied role bindings for users and groups."
  value = {
    users = {
      for key, rb in keycloak_user_roles.this :
      key => {
        realm    = rb.realm_id
        user_id  = rb.user_id
        role_ids = rb.role_ids
      }
    }
    groups = {
      for key, rb in keycloak_group_roles.this :
      key => {
        realm    = rb.realm_id
        group_id = rb.group_id
        role_ids = rb.role_ids
      }
    }
  }
}

output "groups" {
  description = "Map of configured groups keyed by \"<realm>/<name>\"."
  value = {
    for key, g in keycloak_group.this :
    key => {
      id     = g.id
      realm  = g.realm_id
      name   = g.name
      parent = try(local.groups[key].parent, null)
      path   = try(local.groups[key].path, null)
      metadata = {
        attributes = try(local.groups[key].attributes, {})
      }
    }
  }
}

output "default_groups" {
  description = "Default groups configured per realm."
  value = {
    for realm, ids in local.default_groups_resolved :
    realm => ids
  }
}

output "users" {
  description = "Map of seeded users keyed by \"<realm>/<username>\"."
  value = {
    for key, u in keycloak_user.this :
    key => {
      id       = u.id
      realm    = u.realm_id
      username = u.username
    }
  }
}

output "service_accounts" {
  description = "Map of client service account users keyed by \"<realm>/<client_id>\"."
  value = {
    for key, sa in local.service_accounts :
    key => {
      realm     = sa.realm
      client_id = sa.client_id
      user_id   = keycloak_openid_client.this[sa.client_id].service_account_user_id
    }
  }
}
