terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
  }
}

module "keycloak_instance" {
  # Use the local module in the repo root
  source = "../.."

  realms = [
    {
      name         = "demo01"
      display_name = "Demo 01"
    },
    {
      name         = "demo02"
      display_name = "Demo 02"
    }
  ]
}
