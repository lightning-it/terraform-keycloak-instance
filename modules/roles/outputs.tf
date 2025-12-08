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
    "${local.normalized_client_roles[key].client_id}:${local.normalized_client_roles[key].name}" => {
      id        = r.id
      realm     = r.realm_id
      client_id = local.normalized_client_roles[key].client_id
      name      = local.normalized_client_roles[key].name
    } if contains(keys(local.normalized_client_roles), key)
  }
}
