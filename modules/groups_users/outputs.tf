output "groups" {
  description = "Map of configured groups keyed by \"<realm>/<name>\"."
  value = {
    for key, g in keycloak_group.this :
    key => {
      id     = g.id
      realm  = g.realm_id
      name   = g.name
      parent = try(local.normalized_groups[key].parent, null)
      path   = try(local.normalized_groups[key].path, null)
      metadata = {
        attributes = try(local.normalized_groups[key].attributes, {})
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

output "service_accounts" {
  description = "Map of client service account users keyed by \"<realm>/<client_id>\"."
  value = {
    for key, sa in local.normalized_service_accounts :
    key => {
      realm     = sa.realm
      client_id = sa.client_id
      user_id   = var.clients[sa.client_id].service_account_user_id
    }
  }
}
