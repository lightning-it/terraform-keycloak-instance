output "realms" {
  description = "Map of managed realms keyed by name."
  value = {
    for name, r in keycloak_realm.this :
    name => {
      id    = r.id
      realm = r.realm
    }
  }
}

output "theme_settings" {
  description = "Effective theme settings per realm."
  value = {
    for realm, settings in local.theme_settings :
    realm => {
      login_theme   = try(settings.login_theme, null)
      account_theme = try(settings.account_theme, null)
      admin_theme   = try(settings.admin_theme, null)
      email_theme   = try(settings.email_theme, null)
    }
  }
}

output "localization_settings" {
  description = "Localization settings per realm."
  value = {
    for realm, settings in local.localization_settings :
    realm => {
      internationalization_enabled = coalesce(try(settings.internationalization_enabled, null), true)
      supported_locales            = try(settings.supported_locales, null)
      default_locale               = try(settings.default_locale, null)
    }
  }
}

output "event_settings" {
  description = "Event configuration per realm."
  value = {
    for realm, settings in local.event_settings :
    realm => {
      events_enabled               = try(settings.events_enabled, null)
      events_expiration            = try(settings.events_expiration, null)
      events_listeners             = try(settings.events_listeners, null)
      enabled_event_types          = try(settings.enabled_event_types, null)
      admin_events_enabled         = try(settings.admin_events_enabled, null)
      admin_events_details_enabled = try(settings.admin_events_details_enabled, null)
    }
  }
}

output "session_settings" {
  description = "Summary of session timeout settings per realm."
  value = {
    for realm, settings in local.session_settings :
    realm => settings
  }
}

output "token_settings" {
  description = "Summary of token timeout settings per realm."
  value = {
    for realm, settings in local.token_settings :
    realm => settings
  }
}
