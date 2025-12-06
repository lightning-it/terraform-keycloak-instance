output "identity_providers" {
  description = "Map of configured identity providers keyed by \"<realm>/<alias>\"."
  value = merge(
    {
      for key, idp in keycloak_oidc_identity_provider.this :
      key => {
        id            = idp.id
        realm         = idp.realm
        alias         = idp.alias
        provider_type = "oidc"
      }
    },
    {
      for key, idp in keycloak_saml_identity_provider.this :
      key => {
        id            = idp.id
        realm         = idp.realm
        alias         = idp.alias
        provider_type = "saml"
      }
    }
  )
}

output "identity_provider_mappers" {
  description = "Map of identity provider mappers keyed by \"<realm>/<alias>/<name>\"."
  value = {
    for key, m in keycloak_custom_identity_provider_mapper.this :
    key => {
      id     = m.id
      realm  = m.realm
      alias  = m.identity_provider_alias
      name   = m.name
      mapper = m.identity_provider_mapper
    }
  }
}

output "ldap_user_federations" {
  description = "Map of LDAP user federation providers keyed by \"<realm>/<name>\"."
  value = {
    for key, f in keycloak_ldap_user_federation.this :
    key => {
      id             = f.id
      realm          = f.realm_id
      name           = f.name
      connection_url = f.connection_url
      vendor         = try(f.vendor, null)
    }
  }
}

output "kerberos_user_federations" {
  description = "Map of Kerberos user federation providers keyed by \"<realm>/<name>\"."
  value = {
    for key, f in keycloak_custom_user_federation.kerberos :
    key => {
      id             = f.id
      realm          = f.realm_id
      name           = f.name
      kerberos_realm = local.kerberos_user_federations[key].kerberos_realm
    }
  }
}
