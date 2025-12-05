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
