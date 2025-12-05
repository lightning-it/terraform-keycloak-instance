# terraform-keycloak-instance

Terraform module for configuring a full Keycloak instance with realms, clients,
scopes, and roles using the official
[keycloak/keycloak](https://registry.terraform.io/providers/keycloak/keycloak/latest) provider.

This module provides a declarative, GitOps-friendly way to manage base realms,
clients and scopes, and attach realm/client roles to users and groups.

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
| [keycloak_default_groups.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/default_groups) | resource |
| [keycloak_generic_protocol_mapper.client_scope](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_group.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_openid_client.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_default_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_optional_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_optional_scopes) | resource |
| [keycloak_openid_client_scope.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_scope) | resource |
| [keycloak_realm.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_role.client](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.realm](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
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
| <a name="input_realm_roles"></a> [realm\_roles](#input\_realm\_roles) | Realm-level roles to configure. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    composite   = optional(bool)<br/>    composites  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_realms"></a> [realms](#input\_realms) | List of Keycloak realms to manage with this module. | <pre>list(object({<br/>    # Required<br/>    name = string<br/><br/>    # Optional fields — handled with try()/coalesce() in main.tf<br/>    display_name             = optional(string)<br/>    enabled                  = optional(bool)<br/>    login_theme              = optional(string)<br/>    registration_allowed     = optional(bool)<br/>    remember_me              = optional(bool)<br/>    login_with_email_allowed = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_role_bindings"></a> [role\_bindings](#input\_role\_bindings) | Role bindings to users and groups. | <pre>list(object({<br/>    realm        = string<br/>    user_id      = optional(string)<br/>    username     = optional(string)<br/>    group_id     = optional(string)<br/>    group_name   = optional(string)<br/>    realm_roles  = optional(list(string))<br/>    client_roles = optional(map(list(string)))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_roles"></a> [client\_roles](#output\_client\_roles) | Map of configured client roles keyed by "<client\_id>:<role\_name>". |
| <a name="output_client_scopes"></a> [client\_scopes](#output\_client\_scopes) | Map of configured client scopes keyed by scope name. |
| <a name="output_clients"></a> [clients](#output\_clients) | Map of configured clients keyed by client\_id. |
| <a name="output_default_groups"></a> [default\_groups](#output\_default\_groups) | Default groups configured per realm. |
| <a name="output_groups"></a> [groups](#output\_groups) | Map of configured groups keyed by "<realm>/<name>". |
| <a name="output_realm_roles"></a> [realm\_roles](#output\_realm\_roles) | Map of configured realm roles keyed by "<realm>:<role\_name>". |
| <a name="output_realms"></a> [realms](#output\_realms) | Map of managed realms, keyed by realm name. |
| <a name="output_role_bindings"></a> [role\_bindings](#output\_role\_bindings) | Applied role bindings for users and groups. |
<!-- END_TF_DOCS -->