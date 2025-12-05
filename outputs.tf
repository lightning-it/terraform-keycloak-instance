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
