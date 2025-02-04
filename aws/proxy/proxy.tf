# create a service account
resource "harness_platform_service_account" "proxy" {
  account_id = data.harness_platform_current_account.current.id

  identifier = replace(var.name, "-", "_")
  name       = var.name
  email      = "${var.name}@service.harness.io"
}

# with account admin permissions
resource "harness_platform_role_assignments" "proxy" {
  resource_group_identifier = "_all_account_level_resources"
  role_identifier           = "_account_admin"

  principal {
    identifier = harness_platform_service_account.proxy.id
    type       = "SERVICE_ACCOUNT"
  }
}

# generate api key
resource "harness_platform_apikey" "proxy" {
  account_id = data.harness_platform_current_account.current.id

  identifier  = "ccm_autostopping_proxy"
  name        = "ccm autostopping proxy"
  parent_id   = harness_platform_service_account.proxy.id
  apikey_type = "SERVICE_ACCOUNT"

  lifecycle {
    ignore_changes = [
      default_time_to_expire_token,
    ]
  }
}

# and token
resource "harness_platform_token" "proxy" {
  account_id = data.harness_platform_current_account.current.id

  identifier = "token"
  name       = "token"
  parent_id  = harness_platform_service_account.proxy.id

  apikey_type = "SERVICE_ACCOUNT"
  apikey_id   = harness_platform_apikey.proxy.id
}

# allow access inbound on the range of ports autostopping may use, as well as ssh to allow debugging
resource "aws_security_group" "proxy" {
  name        = "${var.name}-proxy"
  description = "Allow ephemeral inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Ephemeral ports for application traffic"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ephemeral ports for ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-proxy"
  }
}

# create the autostopping proxy in a public subnet
resource "harness_autostopping_aws_proxy" "proxy" {
  name               = substr(var.name, 0, 20)
  cloud_connector_id = var.cloud_connector_id
  host_name          = "proxy.example.com"
  region             = data.aws_region.current.name
  vpc                = module.vpc.vpc_id
  security_groups = [
    module.vpc.default_security_group_id,
    aws_security_group.proxy.id
  ]
  machine_type                      = "t3.micro"
  api_key                           = harness_platform_token.proxy.value
  keypair                           = var.key
  allocate_static_ip                = true
  delete_cloud_resources_on_destroy = true
}