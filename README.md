# terraform-keycloak-instance

Terraform Registry: [`lightning-it/instance/keycloak`](https://registry.terraform.io/modules/lightning-it/instance/keycloak/latest)

Terraform module for configuring a full Keycloak instance using the official
[keycloak/keycloak](https://registry.terraform.io/providers/keycloak/keycloak/latest) provider. It provides a declarative,
GitOps-friendly way to manage realms, clients and client scopes, roles and bindings, groups and defaults, users and
service accounts, identity providers, user federation, auth policies (SMTP, password, brute force, OTP), themes,
localization, events, and sessions. This module is intentionally broad in scope: it is designed to manage a full
Keycloak instance (realms, clients, roles, users, identity providers, user federation, policies and sessions) from a
single Terraform configuration.

## Use cases

- Provision base realms (e.g. demo01/demo02) and platform tenants as code
- Manage clients, client scopes, roles, and role bindings with repeatable Terraform plans
- Define groups, default groups, and user/service account assignments consistently across environments
- Integrate with existing identity directories via LDAP/Kerberos user federation
- Enforce consistent auth and session policies (SMTP, password/OTP, brute-force detection, events, and timeouts)

## Example usage

```hcl
terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
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
  version = "1.0.0" # or the current version

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
```

Additional ready-to-run samples mirroring the test fixtures live in:
- `examples/keycloak-smoke` (minimal realm)
- `examples/keycloak-advanced` (broader feature coverage)
- `examples/keycloak-empty` (baseline wiring with everything else omitted)

## Example with clients and roles

```hcl
module "keycloak_instance" {
  source  = "lightning-it/instance/keycloak"
  version = "1.0.0"

  realms = [
    {
      name         = "demo01"
      display_name = "Demo 01"
    }
  ]

  clients = [
    {
      client_id   = "frontend"
      client_type = "public"
      realm       = "demo01"
      name        = "Frontend App"
    }
  ]

  realm_roles = [
    {
      name        = "platform-admin"
      realm       = "demo01"
      description = "Platform administrator"
    }
  ]

  client_roles = [
    {
      client_id   = "frontend"
      realm       = "demo01"
      name        = "app-reader"
      description = "Read access to frontend app"
    }
  ]

  groups = [
    {
      name   = "admins"
      realm  = "demo01"
      attributes = {
        team = ["platform"]
      }
    }
  ]

  users = [
    {
      username   = "alice"
      realm      = "demo01"
      email      = "alice@example.com"
      first_name = "Alice"
      last_name  = "Admin"
      enabled    = true
      initial_password = {
        value     = "ChangeMe123!"
        temporary = true
      }
    }
  ]

  identity_providers = [
    {
      name               = "google"
      alias              = "google"
      realm              = "demo01"
      provider_type      = "oidc"
      enabled            = true
      client_id          = "google-client-id"
      client_secret      = "google-client-secret"
      authorization_url  = "https://accounts.google.com/o/oauth2/v2/auth"
      token_url          = "https://oauth2.googleapis.com/token"
      userinfo_url       = "https://openidconnect.googleapis.com/v1/userinfo"
      issuer             = "https://accounts.google.com"
      default_scopes     = ["openid", "email", "profile"]
      trust_email        = true
      hide_on_login_page = false
    }
  ]
}
```

## Testing

For local testing against a Dockerized Keycloak 26 instance:

```bash
make test-keycloak
```

This will:
- start a local Keycloak container (`tests/keycloak-smoke/docker-compose.yml`)
- run terraform init/apply in `tests/keycloak-smoke`, `tests/keycloak-advanced`, and `tests/keycloak-empty` via the container-wunder-devtools-ee image
- tear down the Keycloak container again

## Future scope

This module started as a realms-only foundation and has been extended to cover clients and client scopes, roles and role bindings, groups and default groups, users and service accounts, identity providers, auth policies, themes, events, sessions and user federation.

Future work may include more advanced features such as:

- user federation mappers and fine-grained tuning
- user profile configuration
- custom authentication flows / executions
- client authorization services (fine-grained IAM policies)
- keystore and certificate management

If you tell me you’re ready to move from “realms-only” to the fuller scope
(clients, roles, users, IdPs, etc.), we can turn those Codex prompts into a
concrete plan for how to grow this module in a way that still feels clean and
maintainable.

## Security & production notes

- Do **not** check real secrets (SMTP passwords, LDAP bind credentials, IdP client secrets, etc.) into version control.
- Use secret managers or Terraform Cloud/HCP/CI variables for sensitive values.
- Review password policies, brute-force settings, and token/session lifetimes carefully before using this in production realms.
- Treat the examples in this README as starting points, not production defaults.

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
| [keycloak_custom_user_federation.kerberos](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/custom_user_federation) | resource |
| [keycloak_default_groups.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/default_groups) | resource |
| [keycloak_generic_protocol_mapper.client_scope](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_group.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_ldap_user_federation.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/ldap_user_federation) | resource |
| [keycloak_oidc_identity_provider.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_identity_provider) | resource |
| [keycloak_openid_client.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_default_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_optional_scopes.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_optional_scopes) | resource |
| [keycloak_openid_client_scope.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_scope) | resource |
| [keycloak_realm.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_realm_events.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_events) | resource |
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
| <a name="input_auth_flow_settings"></a> [auth\_flow\_settings](#input\_auth\_flow\_settings) | Authentication flow and login UX settings per realm. | <pre>list(object({<br/>    realm                          = string<br/>    login_with_email_allowed       = optional(bool)<br/>    duplicate_emails_allowed       = optional(bool)<br/>    reset_password_allowed         = optional(bool)<br/>    remember_me                    = optional(bool)<br/>    verify_email                   = optional(bool)<br/>    registration_allowed           = optional(bool)<br/>    registration_email_as_username = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_bruteforce_settings"></a> [bruteforce\_settings](#input\_bruteforce\_settings) | Brute-force protection settings per realm. | <pre>list(object({<br/>    realm                            = string<br/>    enabled                          = bool<br/>    permanent_lockout                = bool<br/>    max_login_failures               = number<br/>    wait_increment_seconds           = number<br/>    quick_login_check_milli          = number<br/>    minimum_quick_login_wait_seconds = number<br/>    max_failure_wait_seconds         = number<br/>    failure_reset_time_seconds       = number<br/>  }))</pre> | `[]` | no |
| <a name="input_client_roles"></a> [client\_roles](#input\_client\_roles) | Client-specific roles to configure. | <pre>list(object({<br/>    client_id   = string<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    composite   = optional(bool)<br/>    composites  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_client_scopes"></a> [client\_scopes](#input\_client\_scopes) | List of reusable client scopes. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    protocol    = optional(string)<br/>    mappers = optional(list(object({<br/>      name             = string<br/>      protocol         = optional(string)<br/>      protocol_mapper  = string<br/>      consent_required = optional(bool)<br/>      consent_text     = optional(string)<br/>      config           = optional(map(string))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | List of Keycloak clients to configure for this instance. | <pre>list(object({<br/>    client_id                    = string<br/>    client_type                  = string<br/>    name                         = optional(string)<br/>    realm                        = optional(string)<br/>    redirect_uris                = optional(list(string))<br/>    web_origins                  = optional(list(string))<br/>    base_url                     = optional(string)<br/>    standard_flow_enabled        = optional(bool)<br/>    implicit_flow_enabled        = optional(bool)<br/>    direct_access_grants_enabled = optional(bool)<br/>    service_accounts_enabled     = optional(bool)<br/>    frontchannel_logout_enabled  = optional(bool)<br/>    default_scopes               = optional(list(string))<br/>    optional_scopes              = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_theme_hooks"></a> [custom\_theme\_hooks](#input\_custom\_theme\_hooks) | Optional hooks or metadata describing custom theme deployments. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    source_path = optional(string)<br/>    notes       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_default_groups"></a> [default\_groups](#input\_default\_groups) | Default groups to assign to new users per realm. | <pre>list(object({<br/>    realm = string<br/>    names = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_event_listener_hooks"></a> [event\_listener\_hooks](#input\_event\_listener\_hooks) | Optional metadata for custom event listener deployments. | <pre>list(object({<br/>    name       = string<br/>    realm      = optional(string)<br/>    target_url = optional(string)<br/>    notes      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_event_settings"></a> [event\_settings](#input\_event\_settings) | Event configuration per realm (enabled events, storage, listeners). | <pre>list(object({<br/>    realm                        = string<br/>    events_enabled               = optional(bool)<br/>    events_expiration            = optional(number)<br/>    events_listeners             = optional(list(string))<br/>    enabled_event_types          = optional(list(string))<br/>    admin_events_enabled         = optional(bool)<br/>    admin_events_details_enabled = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | List of Keycloak groups to create, including optional attributes and hierarchy. | <pre>list(object({<br/>    name       = string<br/>    realm      = optional(string)<br/>    parent     = optional(string)<br/>    attributes = optional(map(list(string)))<br/>    path       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_provider_mappers"></a> [identity\_provider\_mappers](#input\_identity\_provider\_mappers) | List of identity provider mappers to map external attributes/claims into Keycloak. | <pre>list(object({<br/>    identity_provider_alias = string<br/>    realm                   = optional(string)<br/>    name                    = string<br/>    mapper_type             = string<br/>    config                  = optional(map(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_providers"></a> [identity\_providers](#input\_identity\_providers) | List of identity providers (OIDC/SAML) to configure for this Keycloak instance. | <pre>list(object({<br/>    name               = string<br/>    realm              = optional(string)<br/>    provider_type      = string<br/>    enabled            = optional(bool)<br/>    alias              = optional(string)<br/>    display_name       = optional(string)<br/>    trust_email        = optional(bool)<br/>    store_token        = optional(bool)<br/>    link_only          = optional(bool)<br/>    hide_on_login_page = optional(bool)<br/><br/>    # OIDC-specific<br/>    client_id         = optional(string)<br/>    client_secret     = optional(string)<br/>    authorization_url = optional(string)<br/>    token_url         = optional(string)<br/>    userinfo_url      = optional(string)<br/>    issuer            = optional(string)<br/>    jwks_url          = optional(string)<br/>    default_scopes    = optional(list(string))<br/><br/>    # SAML-specific<br/>    single_sign_on_service_url = optional(string)<br/>    single_logout_service_url  = optional(string)<br/>    entity_id                  = optional(string)<br/>    x509_certificate           = optional(string)<br/>    name_id_policy_format      = optional(string)<br/>    force_authn                = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_kerberos_user_federations"></a> [kerberos\_user\_federations](#input\_kerberos\_user\_federations) | Kerberos user federation providers per realm. | <pre>list(object({<br/>    realm                      = string<br/>    name                       = string<br/>    enabled                    = optional(bool)<br/>    priority                   = optional(number)<br/>    kerberos_realm             = string<br/>    server_principal           = string<br/>    key_tab                    = string<br/>    debug                      = optional(bool)<br/>    allow_password_auth        = optional(bool)<br/>    allow_kerberos_auth        = optional(bool)<br/>    update_profile_first_login = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_ldap_user_federations"></a> [ldap\_user\_federations](#input\_ldap\_user\_federations) | LDAP user federation providers per realm. | <pre>list(object({<br/>    realm                   = string<br/>    name                    = string<br/>    enabled                 = optional(bool)<br/>    priority                = optional(number)<br/>    edit_mode               = optional(string)<br/>    import_enabled          = optional(bool)<br/>    sync_registrations      = optional(bool)<br/>    vendor                  = optional(string)<br/>    username_ldap_attribute = optional(string)<br/>    rdn_ldap_attribute      = optional(string)<br/>    uuid_ldap_attribute     = optional(string)<br/>    user_object_classes     = optional(list(string))<br/>    connection_url          = string<br/>    users_dn                = string<br/>    bind_dn                 = optional(string)<br/>    bind_credential         = optional(string)<br/>    use_truststore_spi      = optional(string)<br/>    trust_email             = optional(bool)<br/>    pagination              = optional(bool)<br/>    start_tls               = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_localization_settings"></a> [localization\_settings](#input\_localization\_settings) | Localization settings per realm (internationalization and locales). | <pre>list(object({<br/>    realm                        = string<br/>    internationalization_enabled = optional(bool)<br/>    supported_locales            = optional(list(string))<br/>    default_locale               = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_otp_settings"></a> [otp\_settings](#input\_otp\_settings) | OTP/MFA configuration per realm. | <pre>list(object({<br/>    realm                 = string<br/>    otp_type              = optional(string)<br/>    otp_alg               = optional(string)<br/>    otp_digits            = optional(number)<br/>    otp_initial_counter   = optional(number)<br/>    otp_look_ahead_window = optional(number)<br/>    otp_period            = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_password_policies"></a> [password\_policies](#input\_password\_policies) | Password policies per realm. | <pre>list(object({<br/>    realm    = string<br/>    policies = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_realm_roles"></a> [realm\_roles](#input\_realm\_roles) | Realm-level roles to configure. | <pre>list(object({<br/>    name        = string<br/>    realm       = optional(string)<br/>    description = optional(string)<br/>    composite   = optional(bool)<br/>    composites  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_realms"></a> [realms](#input\_realms) | List of Keycloak realms to manage with this module. | <pre>list(object({<br/>    # Required<br/>    name = string<br/><br/>    # Optional fields — handled with try()/coalesce() in main.tf<br/>    display_name             = optional(string)<br/>    enabled                  = optional(bool)<br/>    login_theme              = optional(string)<br/>    registration_allowed     = optional(bool)<br/>    remember_me              = optional(bool)<br/>    login_with_email_allowed = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_role_bindings"></a> [role\_bindings](#input\_role\_bindings) | Role bindings to users and groups. | <pre>list(object({<br/>    realm        = string<br/>    user_id      = optional(string)<br/>    username     = optional(string)<br/>    group_id     = optional(string)<br/>    group_name   = optional(string)<br/>    realm_roles  = optional(list(string))<br/>    client_roles = optional(map(list(string)))<br/>  }))</pre> | `[]` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Configuration for client service accounts, including optional role assignments. | <pre>list(object({<br/>    client_id    = string<br/>    realm        = optional(string)<br/>    enabled      = optional(bool)<br/>    attributes   = optional(map(list(string)))<br/>    realm_roles  = optional(list(string))<br/>    client_roles = optional(map(list(string)))<br/>  }))</pre> | `[]` | no |
| <a name="input_session_settings"></a> [session\_settings](#input\_session\_settings) | Session timeout settings per realm. | <pre>list(object({<br/>    realm                                = string<br/>    sso_session_idle_timeout             = optional(number)<br/>    sso_session_max_lifespan             = optional(number)<br/>    sso_session_idle_timeout_remember_me = optional(number)<br/>    sso_session_max_lifespan_remember_me = optional(number)<br/>    offline_session_idle_timeout         = optional(number)<br/>    offline_session_max_lifespan         = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_smtp_settings"></a> [smtp\_settings](#input\_smtp\_settings) | SMTP settings per realm for outgoing email. | <pre>list(object({<br/>    realm        = string<br/>    host         = string<br/>    port         = number<br/>    from         = string<br/>    auth         = bool<br/>    user         = optional(string)<br/>    password     = optional(string)<br/>    ssl          = optional(bool)<br/>    starttls     = optional(bool)<br/>    reply_to     = optional(string)<br/>    from_display = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_theme_settings"></a> [theme\_settings](#input\_theme\_settings) | Theme settings per realm (login, account, admin, email). | <pre>list(object({<br/>    realm         = string<br/>    login_theme   = optional(string)<br/>    account_theme = optional(string)<br/>    admin_theme   = optional(string)<br/>    email_theme   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_token_settings"></a> [token\_settings](#input\_token\_settings) | Token and login timeout settings per realm. | <pre>list(object({<br/>    realm                                   = string<br/>    login_timeout                           = optional(number)<br/>    login_action_timeout                    = optional(number)<br/>    access_token_lifespan                   = optional(number)<br/>    access_token_lifespan_for_implicit_flow = optional(number)<br/>    client_session_idle_timeout             = optional(number)<br/>    client_session_max_lifespan             = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | List of users to seed in Keycloak, including credentials and attributes. | <pre>list(object({<br/>    username         = string<br/>    realm            = optional(string)<br/>    enabled          = optional(bool)<br/>    email            = optional(string)<br/>    first_name       = optional(string)<br/>    last_name        = optional(string)<br/>    attributes       = optional(map(list(string)))<br/>    required_actions = optional(list(string))<br/>    initial_password = optional(object({<br/>      value     = string<br/>      temporary = optional(bool)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_roles"></a> [client\_roles](#output\_client\_roles) | Map of configured client roles keyed by "<client\_id>:<role\_name>". |
| <a name="output_client_scopes"></a> [client\_scopes](#output\_client\_scopes) | Map of configured client scopes keyed by scope name. |
| <a name="output_clients"></a> [clients](#output\_clients) | Map of configured clients keyed by client\_id. |
| <a name="output_custom_theme_hooks"></a> [custom\_theme\_hooks](#output\_custom\_theme\_hooks) | Custom theme hook metadata passed to the module. |
| <a name="output_default_groups"></a> [default\_groups](#output\_default\_groups) | Default groups configured per realm. |
| <a name="output_event_listener_hooks"></a> [event\_listener\_hooks](#output\_event\_listener\_hooks) | Event listener hook metadata passed to the module. |
| <a name="output_event_settings"></a> [event\_settings](#output\_event\_settings) | Event configuration per realm. |
| <a name="output_groups"></a> [groups](#output\_groups) | Map of configured groups keyed by "<realm>/<name>". |
| <a name="output_identity_provider_mappers"></a> [identity\_provider\_mappers](#output\_identity\_provider\_mappers) | Map of identity provider mappers keyed by "<realm>/<alias>/<name>". |
| <a name="output_identity_providers"></a> [identity\_providers](#output\_identity\_providers) | Map of configured identity providers keyed by "<realm>/<alias>". |
| <a name="output_kerberos_user_federations"></a> [kerberos\_user\_federations](#output\_kerberos\_user\_federations) | Map of Kerberos user federation providers keyed by "<realm>/<name>". |
| <a name="output_ldap_user_federations"></a> [ldap\_user\_federations](#output\_ldap\_user\_federations) | Map of LDAP user federation providers keyed by "<realm>/<name>". |
| <a name="output_localization_settings"></a> [localization\_settings](#output\_localization\_settings) | Localization settings per realm. |
| <a name="output_realm_roles"></a> [realm\_roles](#output\_realm\_roles) | Map of configured realm roles keyed by "<realm>:<role\_name>". |
| <a name="output_realms"></a> [realms](#output\_realms) | Map of managed realms, keyed by realm name. |
| <a name="output_role_bindings"></a> [role\_bindings](#output\_role\_bindings) | Applied role bindings for users and groups. |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | Map of client service account users keyed by "<realm>/<client\_id>". |
| <a name="output_session_settings"></a> [session\_settings](#output\_session\_settings) | Summary of session timeout settings per realm. |
| <a name="output_theme_settings"></a> [theme\_settings](#output\_theme\_settings) | Effective theme settings per realm. |
| <a name="output_token_settings"></a> [token\_settings](#output\_token\_settings) | Summary of token timeout settings per realm. |
| <a name="output_users"></a> [users](#output\_users) | Map of seeded users keyed by "<realm>/<username>". |
<!-- END_TF_DOCS -->
