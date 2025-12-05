terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
  }
}

module "keycloak_platform" {
  # Use the local module in the repo root
  source = "../.."

  realms = [
    {
      name         = "tier0"
      display_name = "TIER0"
    },
    {
      name         = "tier1"
      display_name = "TIER1"
    }
  ]
}
