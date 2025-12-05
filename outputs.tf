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
      protocol = s.protocol
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
