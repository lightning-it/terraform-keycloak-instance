terraform {
  required_version = ">= 1.5.7, < 2.0.0"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5"
    }
  }
}

provider "keycloak" {
  url   = "http://host.docker.internal:8080" # Host-IP aus Sicht des Containers
  realm = "master"

  # Für den lokalen Test: admin-cli mit Username/Password
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

module "keycloak_platform" {
  # Modul im Repo-Root
  source = "../.."

  realms = [
    {
      name         = "tier0"
      display_name = "TIER0"
    }
  ]
}
