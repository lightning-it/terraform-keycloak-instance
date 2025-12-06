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
  realms = {
    for r in var.realms :
    r.name => r
  }

  auth_flow_settings = {
    for a in var.auth_flow_settings :
    a.realm => a
  }

  password_policies = {
    for p in var.password_policies :
    p.realm => join(" and ", coalesce(try(p.policies, null), []))
    if length(coalesce(try(p.policies, null), [])) > 0
  }

  bruteforce_settings = {
    for b in var.bruteforce_settings :
    b.realm => b
  }

  otp_settings = {
    for o in var.otp_settings :
    o.realm => o
  }

  theme_settings = {
    for t in var.theme_settings :
    t.realm => t
  }

  localization_settings = {
    for l in var.localization_settings :
    l.realm => l
  }

  event_settings = {
    for e in var.event_settings :
    e.realm => e
  }

  session_settings = {
    for s in var.session_settings :
    s.realm => s
  }

  token_settings = {
    for t in var.token_settings :
    t.realm => t
  }

  smtp_settings = {
    for s in var.smtp_settings :
    s.realm => {
      host                  = s.host
      port                  = s.port
      from                  = s.from
      reply_to              = try(s.reply_to, null)
      reply_to_display_name = try(s.from_display, null)
      from_display          = try(s.from_display, null)
      ssl                   = try(s.ssl, null)
      starttls              = try(s.starttls, null)
    }
  }
}

resource "keycloak_realm" "this" {
  for_each = local.realms

  realm = each.value.name

  enabled                  = coalesce(try(each.value.enabled, null), true)
  display_name             = try(each.value.display_name, null)
  login_theme              = try(coalesce(try(local.theme_settings[each.key].login_theme, null), try(each.value.login_theme, null)), null)
  account_theme            = try(coalesce(try(local.theme_settings[each.key].account_theme, null), try(each.value.account_theme, null)), null)
  admin_theme              = try(coalesce(try(local.theme_settings[each.key].admin_theme, null), try(each.value.admin_theme, null)), null)
  email_theme              = try(coalesce(try(local.theme_settings[each.key].email_theme, null), try(each.value.email_theme, null)), null)
  registration_allowed     = coalesce(try(local.auth_flow_settings[each.key].registration_allowed, null), coalesce(try(each.value.registration_allowed, null), false))
  remember_me              = coalesce(try(local.auth_flow_settings[each.key].remember_me, null), coalesce(try(each.value.remember_me, null), true))
  login_with_email_allowed = coalesce(try(local.auth_flow_settings[each.key].login_with_email_allowed, null), coalesce(try(each.value.login_with_email_allowed, null), true))
  duplicate_emails_allowed = coalesce(try(local.auth_flow_settings[each.key].duplicate_emails_allowed, null), try(each.value.duplicate_emails_allowed, null), false)
  reset_password_allowed   = coalesce(try(local.auth_flow_settings[each.key].reset_password_allowed, null), try(each.value.reset_password_allowed, null), false)
  verify_email             = coalesce(try(local.auth_flow_settings[each.key].verify_email, null), try(each.value.verify_email, null), false)
  registration_email_as_username = coalesce(
    try(local.auth_flow_settings[each.key].registration_email_as_username, null),
    try(each.value.registration_email_as_username, null),
    false
  )

  password_policy = try(local.password_policies[each.key], null)

  sso_session_idle_timeout             = try(local.session_settings[each.key].sso_session_idle_timeout, null)
  sso_session_max_lifespan             = try(local.session_settings[each.key].sso_session_max_lifespan, null)
  sso_session_idle_timeout_remember_me = try(local.session_settings[each.key].sso_session_idle_timeout_remember_me, null)
  sso_session_max_lifespan_remember_me = try(local.session_settings[each.key].sso_session_max_lifespan_remember_me, null)
  offline_session_idle_timeout         = try(local.session_settings[each.key].offline_session_idle_timeout, null)
  offline_session_max_lifespan         = try(local.session_settings[each.key].offline_session_max_lifespan, null)

  access_token_lifespan                   = try(local.token_settings[each.key].access_token_lifespan, null)
  access_token_lifespan_for_implicit_flow = try(local.token_settings[each.key].access_token_lifespan_for_implicit_flow, null)
  client_session_idle_timeout             = try(local.token_settings[each.key].client_session_idle_timeout, null)
  client_session_max_lifespan             = try(local.token_settings[each.key].client_session_max_lifespan, null)

  dynamic "security_defenses" {
    for_each = try(local.bruteforce_settings[each.key].enabled, false) ? [local.bruteforce_settings[each.key]] : []
    content {
      brute_force_detection {
        permanent_lockout                = try(security_defenses.value.permanent_lockout, null)
        max_login_failures               = try(security_defenses.value.max_login_failures, null)
        wait_increment_seconds           = try(security_defenses.value.wait_increment_seconds, null)
        quick_login_check_milli_seconds  = try(security_defenses.value.quick_login_check_milli, null)
        minimum_quick_login_wait_seconds = try(security_defenses.value.minimum_quick_login_wait_seconds, null)
        max_failure_wait_seconds         = try(security_defenses.value.max_failure_wait_seconds, null)
        failure_reset_time_seconds       = try(security_defenses.value.failure_reset_time_seconds, null)
      }
    }
  }

  dynamic "otp_policy" {
    for_each = try([local.otp_settings[each.key]], [])
    content {
      type              = try(otp_policy.value.otp_type, null)
      algorithm         = try(otp_policy.value.otp_alg, null)
      digits            = try(otp_policy.value.otp_digits, null)
      initial_counter   = try(otp_policy.value.otp_initial_counter, null)
      look_ahead_window = try(otp_policy.value.otp_look_ahead_window, null)
      period            = try(otp_policy.value.otp_period, null)
    }
  }

  dynamic "internationalization" {
    for_each = try([local.localization_settings[each.key]], [])
    content {
      supported_locales = try(internationalization.value.supported_locales, null)
      default_locale    = try(internationalization.value.default_locale, null)
    }
  }

  dynamic "smtp_server" {
    for_each = try([local.smtp_settings[each.key]], [])
    content {
      host                  = smtp_server.value.host
      port                  = tostring(smtp_server.value.port)
      from                  = smtp_server.value.from
      reply_to              = try(smtp_server.value.reply_to, null)
      reply_to_display_name = try(smtp_server.value.from_display, null)
      from_display_name     = try(smtp_server.value.from_display, null)
      ssl                   = try(smtp_server.value.ssl, null)
      starttls              = try(smtp_server.value.starttls, null)
    }
  }
}

resource "keycloak_realm_events" "this" {
  for_each = local.event_settings

  realm_id                     = keycloak_realm.this[each.key].id
  events_enabled               = try(each.value.events_enabled, null)
  events_expiration            = try(each.value.events_expiration, null)
  events_listeners             = try(each.value.events_listeners, null)
  enabled_event_types          = try(each.value.enabled_event_types, null)
  admin_events_enabled         = try(each.value.admin_events_enabled, null)
  admin_events_details_enabled = try(each.value.admin_events_details_enabled, null)
}
