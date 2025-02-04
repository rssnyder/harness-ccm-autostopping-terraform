variable "name" {
  type        = string
  default     = "harness-ccm-aws-autostopping-terraform"
  description = "description"
}

variable "key" {
  type        = string
  description = "key pair for accessing application vm over ssh"
}

variable "cloud_connector_id" {
  type        = string
  description = "ID of the cloud connector"
}