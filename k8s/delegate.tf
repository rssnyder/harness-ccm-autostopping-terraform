# generate a delegate token for this cluster
resource "harness_platform_delegatetoken" "this" {
  name       = var.name
  account_id = data.harness_platform_current_account.current.id
}

# deploy the harness delegate
module "delegate" {
  source  = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  account_id       = data.harness_platform_current_account.current.id
  delegate_token   = harness_platform_delegatetoken.this.value
  delegate_name    = var.name
  deploy_mode      = "KUBERNETES"
  namespace        = "harness-delegate-ng"
  manager_endpoint = "https://app.harness.io/gratis"
  delegate_image   = "harness/delegate:25.01.85000"
  replicas         = 1
  upgrader_enabled = false
}