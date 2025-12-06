# terraform-keycloak-instance

Terraform module for configuring a full Keycloak instance with realms, clients,
scopes, roles, groups, users, service accounts, and identity providers using the official
[keycloak/keycloak](https://registry.terraform.io/providers/keycloak/keycloak/latest) provider.

This module provides a declarative, GitOps-friendly way to manage base realms,
clients and scopes, attach realm/client roles to users and groups, seed users,
configure client service accounts, and integrate external identity providers.

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
    }
  ]

  clients = [
    {
      client_id                    = "frontend"
      client_type                  = "public"
      realm                        = "tier0"
      name                         = "Frontend SPA"
      redirect_uris                = ["https://app.example.com/*"]
      web_origins                  = ["+"]
      standard_flow_enabled        = true
      implicit_flow_enabled        = false
      direct_access_grants_enabled = false
      default_scopes               = ["profile", "email", "app-profile"]
      optional_scopes              = ["address"]
    },
    {
      client_id                    = "backend-api"
      client_type                  = "confidential"
      realm                        = "tier0"
      name                         = "Backend API"
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
    },
    {
      name        = "platform-service"
      realm       = "tier0"
      description = "Platform service role"
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

  groups = [
    {
      name   = "admins"
      realm  = "tier0"
      attributes = {
        team = ["platform"]
      }
    },
    {
      name   = "users"
      realm  = "tier0"
    },
    {
      name   = "developers"
      realm  = "tier0"
      parent = "users"
    }
  ]

  default_groups = [
    {
      realm = "tier0"
      names = ["users"]
    }
  ]

  users = [
    {
      username   = "alice"
      realm      = "tier0"
      email      = "alice@example.com"
      first_name = "Alice"
      last_name  = "Admin"
      enabled    = true
      attributes = {
        department = ["platform"]
      }
      initial_password = {
        value     = "ChangeMe123!"
        temporary = true
      }
    }
  ]

  service_accounts = [
    {
      client_id   = "backend-api"
      realm       = "tier0"
      enabled     = true
      realm_roles = ["platform-service"]
    }
  ]

  identity_providers = [
    {
      name          = "google"
      alias         = "google"
      realm         = "tier0"
      provider_type = "oidc"
      enabled       = true
      display_name  = "Google"
      trust_email   = true
      store_token   = false

      client_id      = "your-google-client-id"
      client_secret  = "your-google-client-secret"
      issuer         = "https://accounts.google.com"
      default_scopes = ["openid", "email", "profile"]
    }
  ]

  identity_provider_mappers = [
    {
      identity_provider_alias = "google"
      realm                   = "tier0"
      name                    = "google-email-to-username"
      mapper_type             = "oidc-user-attribute-idp-mapper"
      config = {
        "syncMode"       = "IMPORT"
        "claim"          = "email"
        "user.attribute" = "email"
      }
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0, < 2.0.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [keycloak_custom_identity_provider_mapper.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/custom_identity_provider_mapper) | resource |
| [keycloak_default_groups.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/default_groups) | resource |
| [keycloak_generic_protocol_mapper.client_scope](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_group.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_oidc_identity_provider.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_identity_provider) | resource |
| [keycloak_openid_client.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_default_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_optional_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_optional_scopes) | resource |
| [keycloak_openid_client_scope.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_scope) | resource |
| [keycloak_realm.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_role.client](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.realm](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
| [keycloak_saml_identity_provider.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_identity_provider) | resource |
| [keycloak_user.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user_roles.service_accounts](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_roles) | resource |
| [keycloak_user_roles.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_roles) | resource |
| [keycloak_group.by_name](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/data-sources/group) | data source |
| [keycloak_user.by_username](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_roles"></a> [client\_roles](#input\_client\_roles) | Client-specific roles to configure. | <pre>list(object({<br/>    client_id   = string<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    composite   = optional(bool)<br/>    composites  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_client_scopes"></a> [client\_scopes](#input\_client\_scopes) | List of reusable client scopes. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    protocol    = optional(string)<br/>    mappers = optional(list(object({<br/>      name             = string<br/>      protocol         = optional(string)<br/>      protocol_mapper  = string<br/>      consent_required = optional(bool)<br/>      consent_text     = optional(string)<br/>      config           = optional(map(string))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | List of Keycloak clients to configure for this instance. | <pre>list(object({<br/>    client_id                    = string<br/>    client_type                  = string<br/>    name                         = optional(string)<br/>    realm                        = optional(string)<br/>    redirect_uris                = optional(list(string))<br/>    web_origins                  = optional(list(string))<br/>    base_url                     = optional(string)<br/>    standard_flow_enabled        = optional(bool)<br/>    implicit_flow_enabled        = optional(bool)<br/>    direct_access_grants_enabled = optional(bool)<br/>    service_accounts_enabled     = optional(bool)<br/>    frontchannel_logout_enabled  = optional(bool)<br/>    default_scopes               = optional(list(string))<br/>    optional_scopes              = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_default_groups"></a> [default\_groups](#input\_default\_groups) | Default groups to assign to new users per realm. | <pre>list(object({<br/>    realm = string<br/>    names = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | List of Keycloak groups to create, including optional attributes and hierarchy. | <pre>list(object({<br/>    name       = string<br/>    realm      = optional(string)<br/>    parent     = optional(string)<br/>    attributes = optional(map(list(string)))<br/>    path       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_provider_mappers"></a> [identity\_provider\_mappers](#input\_identity\_provider\_mappers) | List of identity provider mappers to map external attributes/claims into Keycloak. | <pre>list(object({<br/>    identity_provider_alias = string<br/>    realm                   = optional(string)<br/>    name                    = string<br/>    mapper_type             = string<br/>    config                  = optional(map(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_providers"></a> [identity\_providers](#input\_identity\_providers) | List of identity providers (OIDC/SAML) to configure for this Keycloak instance. | <pre>list(object({<br/>    name               = string<br/>    realm              = optional(string)<br/>    provider_type      = string<br/>    enabled            = optional(bool)<br/>    alias              = optional(string)<br/>    display_name       = optional(string)<br/>    trust_email        = optional(bool)<br/>    store_token        = optional(bool)<br/>    link_only          = optional(bool)<br/>    hide_on_login_page = optional(bool)<br/><br/>    # OIDC-specific<br/>    client_id         = optional(string)<br/>    client_secret     = optional(string)<br/>    authorization_url = optional(string)<br/>    token_url         = optional(string)<br/>    userinfo_url      = optional(string)<br/>    issuer            = optional(string)<br/>    jwks_url          = optional(string)<br/>    default_scopes    = optional(list(string))<br/><br/>    # SAML-specific<br/>    single_sign_on_service_url = optional(string)<br/>    single_logout_service_url  = optional(string)<br/>    entity_id                  = optional(string)<br/>    x509_certificate           = optional(string)<br/>    name_id_policy_format      = optional(string)<br/>    force_authn                = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_realm_roles"></a> [realm\_roles](#input\_realm\_roles) | Realm-level roles to configure. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    composite   = optional(bool)<br/>    composites  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_realms"></a> [realms](#input\_realms) | List of Keycloak realms to manage with this module. | <pre>list(object({<br/>    # Required<br/>    name = string<br/><br/>    # Optional fields — handled with try()/coalesce() in main.tf<br/>    display_name             = optional(string)<br/>    enabled                  = optional(bool)<br/>    login_theme              = optional(string)<br/>    registration_allowed     = optional(bool)<br/>    remember_me              = optional(bool)<br/>    login_with_email_allowed = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_role_bindings"></a> [role\_bindings](#input\_role\_bindings) | Role bindings to users and groups. | <pre>list(object({<br/>    realm        = string<br/>    user_id      = optional(string)<br/>    username     = optional(string)<br/>    group_id     = optional(string)<br/>    group_name   = optional(string)<br/>    realm_roles  = optional(list(string))<br/>    client_roles = optional(map(list(string)))<br/>  }))</pre> | `[]` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Configuration for client service accounts, including optional role assignments. | <pre>list(object({<br/>    client_id    = string<br/>    realm        = optional(string)<br/>    enabled      = optional(bool)<br/>    attributes   = optional(map(list(string)))<br/>    realm_roles  = optional(list(string))<br/>    client_roles = optional(map(list(string)))<br/>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | List of users to seed in Keycloak, including credentials and attributes. | <pre>list(object({<br/>    username         = string<br/>    realm            = optional(string)<br/>    enabled          = optional(bool)<br/>    email            = optional(string)<br/>    first_name       = optional(string)<br/>    last_name        = optional(string)<br/>    attributes       = optional(map(list(string)))<br/>    required_actions = optional(list(string))<br/>    initial_password = optional(object({<br/>      value     = string<br/>      temporary = optional(bool)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_roles"></a> [client\_roles](#output\_client\_roles) | Map of configured client roles keyed by "<client\_id>:<role\_name>". |
| <a name="output_client_scopes"></a> [client\_scopes](#output\_client\_scopes) | Map of configured client scopes keyed by scope name. |
| <a name="output_clients"></a> [clients](#output\_clients) | Map of configured clients keyed by client\_id. |
| <a name="output_default_groups"></a> [default\_groups](#output\_default\_groups) | Default groups configured per realm. |
| <a name="output_groups"></a> [groups](#output\_groups) | Map of configured groups keyed by "<realm>/<name>". |
| <a name="output_identity_provider_mappers"></a> [identity\_provider\_mappers](#output\_identity\_provider\_mappers) | Map of identity provider mappers keyed by "<realm>/<alias>/<name>". |
| <a name="output_identity_providers"></a> [identity\_providers](#output\_identity\_providers) | Map of configured identity providers keyed by "<realm>/<alias>". |
| <a name="output_realm_roles"></a> [realm\_roles](#output\_realm\_roles) | Map of configured realm roles keyed by "<realm>:<role\_name>". |
| <a name="output_realms"></a> [realms](#output\_realms) | Map of managed realms, keyed by realm name. |
| <a name="output_role_bindings"></a> [role\_bindings](#output\_role\_bindings) | Applied role bindings for users and groups. |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | Map of client service account users keyed by "<realm>/<client\_id>". |
| <a name="output_users"></a> [users](#output\_users) | Map of seeded users keyed by "<realm>/<username>". |
<!-- END_TF_DOCS -->
