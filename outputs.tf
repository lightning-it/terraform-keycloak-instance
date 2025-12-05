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
