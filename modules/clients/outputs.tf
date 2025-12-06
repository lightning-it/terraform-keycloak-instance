output "clients" {
  description = "Map of configured clients keyed by client_id."
  value = {
    for client_id, c in keycloak_openid_client.this :
    client_id => {
      id                      = c.id
      realm                   = c.realm_id
      client_id               = c.client_id
      service_account_user_id = c.service_account_user_id
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
