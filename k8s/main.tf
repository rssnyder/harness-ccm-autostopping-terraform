data "harness_platform_current_account" "current" {}

locals {
  name_identifier = replace(replace(var.name, " ", "_"), "-", "_")
}