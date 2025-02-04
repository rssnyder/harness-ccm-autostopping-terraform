# create a rule for the application for a web service and ssh
resource "harness_autostopping_rule_vm" "application" {
  name               = "${var.name}-application"
  cloud_connector_id = var.cloud_connector_id
  idle_time_mins     = 5
  filter {
    vm_ids  = [aws_instance.application.id]
    regions = [data.aws_region.current.name]
  }
  tcp {
    proxy_id = harness_autostopping_aws_proxy.proxy.id
    ssh {
      port = 22
    }
    forward_rule {
      port = 80
    }
  }
}