variable "loc" {
  description = "Default Azure Location"
  default     = "westus"
}

variable "webapplocs" {
  default = [ "eastus2", "centralus", "westus" ]
}

variable "tags" {
  default = {
    source  = "Terraform"
    env     = "training"
  }
}
