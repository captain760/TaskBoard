terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_integer" "ri" {
	min = 10000
	max = 99999
}

resource "azurerm_resource_group" "app_group" {
  name     = "ContactBookRG${random_integer.ri.result}"
  location = "westeurope"
}

resource "azurerm_service_plan" "app_sp" {
	name = "contact-book-plan-${random_integer.ri.result}"
	location = azurerm_resource_group.app_group.location
	resource_group_name = azurerm_resource_group.app_group.name
	os_type = "Linux"
	sku_name = "F1"
}

resource "azurerm_linux_web_app" "app_service" {
  name                = "contact-book-app-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_service_plan.app_sp.location
  service_plan_id     = azurerm_service_plan.app_sp.id
  
  site_config{
	application_stack {
		node_version = "16-lts"
	}
	always_on = false
  }
}

resource "azurerm_app_service_source_control" "app_source" {
  app_id   = azurerm_linux_web_app.app_service.id
  repo_url = "https://github.com/nakov/ContactBook"
  branch   = "master"
  use_manual_integration = true
}