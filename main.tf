# module "scaffold" {
#   source = "github.com/ilmaestro/terraform-module-scaffold/scaffold"
# }

resource "azurerm_resource_group" "webapps" {
  name      = "WebApps"
  location  = "${var.loc}"
  tags      = "${var.tags}"
}

resource "random_string" "webapprnd" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_container_registry" "acr" {
  name                     = "acr${random_string.webapprnd.result}"
  resource_group_name      = "${azurerm_resource_group.webapps.name}"
  location                 = "${azurerm_resource_group.webapps.location}"
  sku                      = "Basic"
  admin_enabled            = true
  tags                     = "${var.tags}"
}

resource "azurerm_app_service_plan" "main" {
  count               = 1
  name                = "plan-main-${var.webapplocs[count.index]}"
  location            = "${var.webapplocs[count.index]}"
  resource_group_name = "${azurerm_resource_group.webapps.name}"
  tags                = "${azurerm_resource_group.webapps.tags}"

  kind                = "Linux"
  reserved            = true

  sku {
      tier = "Standard"
      size = "S1"
  }
}

resource "azurerm_app_service" "voyager" {
  count               = 1
  name                = "webapp-${random_string.webapprnd.result}-${var.webapplocs[count.index]}"
  location            = "${var.webapplocs[count.index]}"
  resource_group_name = "${azurerm_resource_group.webapps.name}"
  tags                = "${azurerm_resource_group.webapps.tags}"

  app_service_plan_id = "${element(azurerm_app_service_plan.main.*.id, count.index)}"

  site_config {
    app_command_line = ""
    use_32_bit_worker_process = "true"
    ip_restriction {
      ip_address  = "66.193.107.7"
    }   
    linux_fx_version = "KUBE|${base64encode(file("kubernetes-voyager.yml"))}"
    #linux_fx_version = "COMPOSE|${base64encode(file("docker-compose-voyager.yml"))}"
    #linux_fx_version = "DOCKER|appsvcsample/python-helloworld:latest"
    #linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/samples/blazor:v1"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "${azurerm_container_registry.acr.admin_username}"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "${azurerm_container_registry.acr.admin_password}"
  }
}

# output "webapp_ids" {
#   description = "ids of the web apps provisioned."
#   value       = "${azurerm_app_service.voyager.*.id}"
# }

# https://merrell.dev/posts/2018/09/28/azure-web-apps-for-containers-using-terraform/
