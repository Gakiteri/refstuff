### RESOURCE GROUPS ###
resource "azurerm_resource_group" "rg-01" {
  name     = var.rg-01-name
  location = var.region
  tags     = var.tags
}


### STORAGE ACCOUNT ###
resource "azurerm_storage_account" "st-backend" {
  name                     = var.st-backend.name
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.rg-01.name
  location                 = azurerm_resource_group.rg-01.location
  account_tier             = var.st-backend.tier
  account_replication_type = var.st-backend.replication
}
resource "azurerm_storage_container" "st-backend-container" {
  for_each              = var.st-backend-containers

  name                  = each.value.name
  container_access_type = each.value.access
  storage_account_name  = azurerm_storage_account.st-backend.name
}


### KUBERNETES ###
resource "azurerm_kubernetes_cluster" "kube-01" {
  name                = var.kube-01.name
  dns_prefix          = var.kube-01.dns-prefix
  tags                = var.tags
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name

  default_node_pool {
    name       = var.kube-01.node-name
    node_count = var.kube-01.node-count
    vm_size    = var.kube-01.node-vm
  }

  identity {
    type = "SystemAssigned"
  }
}


### NETWORKS ###
resource "azurerm_virtual_network" "vnet-01" {
  name                = var.vnet-01.name
  tags                = var.tags
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  address_space       = [var.vnet-01.address]
  dns_servers         = [var.vnet-01.dns]
}
resource "azurerm_subnet" "vnet-01-snet-01" {
  name                 = var.vnet-01.snet-01-name
  address_prefixes     = [var.vnet-01.snet-01-address]
  resource_group_name  = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
}
resource "azurerm_public_ip" "pip-01" {
  name                = var.pip-01.name
  tags                = var.tags
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  allocation_method   = var.pip-01.allocation
  sku                 = var.pip-01.sku
  sku_tier            = var.pip-01.sku-tier
  domain_name_label   = var.pip-01.dns-name
  ip_version          = var.pip-01.ip-version
  availability_zone   = var.pip-01.zone

}


### NETWORK SECURITY GROUP ###
resource "azurerm_network_security_group" "nsg-01" {
  name                = var.nsg-01-name
  tags                = var.tags
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
}
resource "azurerm_network_security_rule" "nsg-01-nsgsr-01" {
  for_each = var.nsg-01-sec-rules

  name                                       = each.value.name
  priority                                   = each.value.priority
  direction                                  = each.value.direction
  access                                     = each.value.access
  protocol                                   = each.value.protocol
  source_address_prefix                      = each.value.source-address
  source_port_range                          = each.value.source-port
  destination_address_prefix                 = each.value.destination-address
  destination_port_range                     = each.value.destination-port
  resource_group_name                        = azurerm_resource_group.rg-01.name
  network_security_group_name                = azurerm_network_security_group.nsg-01.name
}


### VMS ###
locals {
  vm-01-nic-name    = "${var.vm-01.name}-nic"
  vm-01-osdisk-name = "${var.vm-01.name}-osdisk"
}

resource "azurerm_network_interface" "nic-01-01" {
  name                = local.vm-01-nic-name
  tags                = var.tags
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name

  ip_configuration {
    name                          = var.vm-01.nic-ip-name
    private_ip_address_allocation = var.vm-01.nic-ip-type
    subnet_id                     = azurerm_subnet.vnet-01-snet-01.id
    public_ip_address_id          = azurerm_public_ip.pip-01.id
  }
}
resource "azurerm_network_interface_security_group_association" "vm-01-nsg-01" {
  network_interface_id      = azurerm_network_interface.nic-01-01.id
  network_security_group_id = azurerm_network_security_group.nsg-01.id
}


resource "azurerm_linux_virtual_machine" "vm-01" {
  name                  = var.vm-01.name
  tags                  = var.tags
  resource_group_name   = azurerm_resource_group.rg-01.name
  location              = azurerm_resource_group.rg-01.location
  size                  = var.vm-01.size

  network_interface_ids = [
    azurerm_network_interface.nic-01-01.id
  ]

  admin_username                  = var.vm-01.user
  admin_password                  = var.vm-01.pass
  disable_password_authentication = var.vm-01.pass-auth

  os_disk {
    name                 = local.vm-01-osdisk-name
    disk_size_gb         = var.vm-01.osdisk-size
    caching              = var.vm-01.osdisk-cache
    storage_account_type = var.vm-01.osdisk-storage-acc
  }

  source_image_reference {
    publisher = var.vm-01.image-publisher
    offer     = var.vm-01.image-offer
    sku       = var.vm-01.image-sku
    version   = var.vm-01.image-version
  }
}

resource "azurerm_managed_disk" "vm-01-datadisk-01" {
  for_each             = var.vm-01-disks

  name                 = each.value.name
  location             = azurerm_resource_group.rg-01.location
  resource_group_name  = azurerm_resource_group.rg-01.name
  disk_size_gb         = each.value.size
  storage_account_type = each.value.storage
  create_option        = each.value.create
  tags                 = azurerm_linux_virtual_machine.vm-01.tags
}

resource "azurerm_virtual_machine_extension" "vm-01-extension-01" {
  name                 = var.vm-01-extension.name
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-01.id
  tags                 = azurerm_linux_virtual_machine.vm-01.tags
  publisher            = var.vm-01-extension.publisher
  type                 = var.vm-01-extension.type
  type_handler_version = var.vm-01-extension.type-version

  settings = <<SETTINGS
      {
        "script": "${base64encode(file(var.vm-01-extension.file))}"
      }
SETTINGS
}

###############################################################

## VM AUTO ##
resource "azurerm_network_interface" "nic-test" {
  for_each = var.vm-test

  name                = "${each.value.name}-nic"
  tags                = var.tags-unrequired
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name

  ip_configuration {
    name                          = each.value.nic-ip-name
    private_ip_address_allocation = each.value.nic-ip-type
    subnet_id                     = azurerm_subnet.snet-01-01.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-test" {
  for_each = var.vm-test

  name                  = each.value.name
  tags                  = var.tags-unrequired
  resource_group_name   = azurerm_resource_group.rg-01.name
  location              = azurerm_resource_group.rg-01.location
  size                  = each.value.size
  network_interface_ids = [
    azurerm_network_interface.nic-test[each.key].id
  ]

  admin_username                  = each.value.user
  admin_password                  = each.value.pass
  disable_password_authentication = each.value.pass-auth

  os_disk {
    name                 = "${each.value.name}-osdisk"
    disk_size_gb         = each.value.osdisk-size
    caching              = each.value.osdisk-cache
    storage_account_type = each.value.osdisk-storage-acc
  }

  source_image_reference {
    publisher = each.value.image-publisher
    offer     = each.value.image-offer
    sku       = each.value.image-sku
    version   = each.value.image-version
  }
}

### KUBERNETES ###
resource "azurerm_kubernetes_cluster" "kube-01" {
  name                = var.kube-01.name
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  dns_prefix          = var.kube-01.dns-prefix
  tags = var.tags

  default_node_pool {
    name       = var.kube-01.node-name
    node_count = var.kube-01.node-count
    vm_size    = var.kube-01.node-vm
  }

  enable_auto_scaling {
    min_count = var.kube-01.scaling-min
    max_count = var.kube-01.scaling-max
  }

#  identity {
#    type = "SystemAssigned"
#  }
  service_principal {
    client_id     = var.service_principal.kube-id
    client_secret = var.service_principal.kube-secret
  }

}

###############################################################
