// NOTE: This example is exercised by `make test-keycloak` and should stay in sync
// with the testing description in README.md.
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
  url   = "http://host.docker.internal:8080"
  realm = "master"

  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
}

module "keycloak_instance" {
  source = "../.."

  realms = [
    {
      name         = "demo01"
      display_name = "DEMO01"
    }
  ]
}
