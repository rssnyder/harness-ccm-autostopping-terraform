# create kubernetes connector that leverages the delegate for authentication
resource "harness_platform_connector_kubernetes" "this" {
  identifier = local.name_identifier
  name       = var.name

  inherit_from_delegate {
    delegate_selectors = [var.name]
  }
}

# create a ccm kubernetes connector to start gathering cost and usage metrics, and enable autostopping
resource "harness_platform_connector_kubernetes_cloud_cost" "this" {
  identifier = "${local.name_identifier}_ccm"
  name       = "${var.name}_ccm"

  features_enabled = ["VISIBILITY", "OPTIMIZATION"]
  connector_ref    = harness_platform_connector_kubernetes.this.id
}