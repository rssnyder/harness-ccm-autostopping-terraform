# create a service account
resource "harness_platform_service_account" "this" {
  account_id = data.harness_platform_current_account.current.id

  identifier = replace(var.name, "-", "_")
  name       = var.name
  email      = "${var.name}@service.harness.io"
}

# with account admin permissions
resource "harness_platform_role_assignments" "this" {
  resource_group_identifier = "_all_account_level_resources"
  role_identifier           = "_account_admin"

  principal {
    identifier = harness_platform_service_account.this.id
    type       = "SERVICE_ACCOUNT"
  }
}

# generate api key
resource "harness_platform_apikey" "this" {
  account_id = data.harness_platform_current_account.current.id

  identifier  = "ccm_autostopping_proxy"
  name        = "ccm autostopping proxy"
  parent_id   = harness_platform_service_account.this.id
  apikey_type = "SERVICE_ACCOUNT"

  lifecycle {
    ignore_changes = [
      default_time_to_expire_token,
    ]
  }
}

# and token
resource "harness_platform_token" "this" {
  account_id = data.harness_platform_current_account.current.id

  identifier = "token"
  name       = "token"
  parent_id  = harness_platform_service_account.this.id

  apikey_type = "SERVICE_ACCOUNT"
  apikey_id   = harness_platform_apikey.this.id
}

# deploy the harness autostopping controller and router
resource "helm_release" "autostopping" {
  repository       = "https://rssnyder.github.io/charts"
  chart            = "harness-ccm-autostopping"
  name             = "harness-ccm-autostopping"
  namespace        = "harness-autostopping"
  create_namespace = true

  set {
    name  = "accountId"
    value = data.harness_platform_current_account.current.id
  }

  set {
    name  = "connectorId"
    value = harness_platform_connector_kubernetes_cloud_cost.this.id
  }

  set_sensitive {
    name  = "apiToken"
    value = harness_platform_token.this.value
    type  = "string"
  }
}
