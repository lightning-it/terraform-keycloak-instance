variable "realms" {
  description = "List of Keycloak realms to manage with this module."
  type = list(object({
    # Required
    name = string

    # Optional fields — handled with try()/coalesce() in main.tf
    display_name             = optional(string)
    enabled                  = optional(bool)
    login_theme              = optional(string)
    registration_allowed     = optional(bool)
    remember_me              = optional(bool)
    login_with_email_allowed = optional(bool)
  }))

  default = []
}