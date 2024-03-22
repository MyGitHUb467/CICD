# Azure provider configuration
provider "azurerm" {
  features {}

  subscription_id   = "74f18b4b-73a2-49ee-a8b5-9e6f8c8ec835"
  tenant_id         = "8d8d4417-60ec-4a46-ae73-5710d3caca54"
  client_id         = "12703015-a0a4-4368-916e-0ae47e8d2dc0"
  client_secret     = "CDg8Q~Hx6Gu7mM1E3-jN~u3O-1~jPjv5SyrwQb4G"
}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
  }
}

# Key Vault
resource "azurerm_key_vault" "example" {
  name                        = "example-key-vault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  tags = {
    environment = "dev"
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "adminuser"

    admin_ssh_key {
      username   = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }

  tags = {
    environment = "dev"
  }
}
