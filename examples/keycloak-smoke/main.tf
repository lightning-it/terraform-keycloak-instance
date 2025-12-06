terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5"
    }
  }
}

provider "keycloak" {
  url   = "https://keycloak.example.com"
  realm = "master"

  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

module "keycloak_instance" {
  source  = "../.."
  version = ">= 1.0.0"

  realms = [
    {
      name         = "demo01"
      display_name = "DEMO01"
    }
  ]
}
