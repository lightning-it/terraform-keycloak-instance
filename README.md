# terraform-keycloak-config

Terraform module for configuring Keycloak realms using the official
[keycloak/keycloak](https://registry.terraform.io/providers/keycloak/keycloak/latest) provider.

This module provides a declarative way to manage one or more Keycloak realms as
part of your platform configuration.

## Use cases

- Provisioning base realms (e.g. `tier0`, `tier1`) for your platform
- Enforcing consistent realm settings (login theme, registration options, etc.)
- Managing Keycloak realm configuration via GitOps / Terraform

## Example usage

```hcl
terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5"
    }
  }
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "keycloak" {
  url           = "https://keycloak.example.com"
  realm         = "master"
  client_id     = "terraform"
  client_secret = "replace-me"
}

module "keycloak_instance" {
  source  = "lightning-it/instance/keycloak"
  version = "1.0.0" # or the current release

  realms = [
    {
      name         = "tier0"
      display_name = "TIER0"
    },
    {
      name                     = "tier1"
      display_name             = "TIER1"
      enabled                  = true
      login_theme              = "keycloak"
      registration_allowed     = false
      remember_me              = true
      login_with_email_allowed = true
    }
  ]

  clients = [
    {
      client_id                 = "frontend"
      client_type               = "public"
      realm                     = "tier0"
      name                      = "Frontend SPA"
      redirect_uris             = ["https://app.example.com/*"]
      web_origins               = ["+"]
      standard_flow_enabled     = true
      implicit_flow_enabled     = false
      direct_access_grants_enabled = false
      default_scopes            = ["profile", "email", "app-profile"]
      optional_scopes           = ["address"]
    },
    {
      client_id                    = "backend"
      client_type                  = "confidential"
      realm                        = "tier0"
      name                         = "Backend Service"
      service_accounts_enabled     = true
      direct_access_grants_enabled = false
      standard_flow_enabled        = false
      implicit_flow_enabled        = false
      default_scopes               = ["profile", "email"]
    }
  ]

  client_scopes = [
    {
      name        = "app-profile"
      realm       = "tier0"
      description = "Expose app-specific profile data"
      protocol    = "openid-connect"

      mappers = [
        {
          name            = "app_role"
          protocol_mapper = "oidc-usermodel-attribute-mapper"
          config = {
            "user.attribute"       = "app_role"
            "claim.name"           = "app_role"
            "jsonType.label"       = "String"
            "id.token.claim"       = "true"
            "access.token.claim"   = "true"
            "userinfo.token.claim" = "true"
          }
        }
      ]
    }
  ]

  realm_roles = [
    {
      name        = "platform-admin"
      realm       = "tier0"
      description = "Platform administrator"
    }
  ]

  client_roles = [
    {
      client_id   = "frontend"
      realm       = "tier0"
      name        = "app-reader"
      description = "Read access to frontend app"
    }
  ]

  role_bindings = [
    {
      realm       = "tier0"
      username    = "alice"
      realm_roles = ["platform-admin"]
    },
    {
      realm        = "tier0"
      group_name   = "developers"
      client_roles = {
        frontend = ["app-reader"]
      }
    }
  ]
}
```

## Inputs and outputs

The tables below are generated automatically by `terraform-docs` from
`variables.tf` and `outputs.tf`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0, < 2.0.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement_keycloak) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_keycloak"></a> [keycloak](#provider_keycloak) | 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [keycloak_realm.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_realms"></a> [realms](#input_realms) | List of Keycloak realms to manage with this module. | <pre>list(object({<br/>    # Required<br/>    name = string<br/><br/>    # Optional fields — handled with try()/coalesce() in main.tf<br/>    display_name             = optional(string)<br/>    enabled                  = optional(bool)<br/>    login_theme              = optional(string)<br/>    registration_allowed     = optional(bool)<br/>    remember_me              = optional(bool)<br/>    login_with_email_allowed = optional(bool)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_realms"></a> [realms](#output_realms) | Map of managed realms, keyed by realm name. |
<!-- END_TF_DOCS -->
