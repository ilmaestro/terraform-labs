variable "loc" {
  description = "Default Azure Location"
  default     = "westus"
}

variable "tags" {
  default = {
    source  = "Terraform"
    env     = "training"
  }
}
