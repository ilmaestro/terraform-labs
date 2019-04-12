variable "loc" {
  description = "Default Azure Location"
  default     = "westus"
}

variable "webapplocs" {
  default = []
}

variable "tags" {
  default = {
    source  = "Terraform"
    env     = "training"
  }
}
