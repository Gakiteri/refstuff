### SECRETS ###
### SUBSCRIPTIONS ###
variable "subscription-id" {
  type = string
}


### GLOBAL ###
variable "region" {
  type = string
  default = "westeurope"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "main"
  }
}


### RESOURCE GROUPS ###
variable "rg-01-name" {
  type = string
}


### STORAGE ACCOUNTS ###
variable "st-backend" {
  type = map(string)
}
variable "st-backend-containers" {
  type = map(object({
    name   = string
    access = string
  }))
}


### KUBERNETES ###
variable "kube-01" {
  type = map(string)
}


### NETWORKS ###
variable "vnet-01" {
  type = map(string)
}


### PUBLIC IPS ###
variable "pip-01" {
  type = map(string)
}


### NETWORK SECURITY RULES ###
variable "nsg-01-name" {
  type = string
}
variable "nsg-01-sec-rules" {
  type = map(object({
    name                = string
    priority            = number
    direction           = string
    access              = string
    protocol            = string
    source-address      = string
    source-port         = string
    destination-address = string
    destination-port    = string
  }))
}


### VMS ###
variable "vm-01" {
  type = map(string)
}
variable "vm-01-disks" {
  type = map(object({
    name        = string
    size        = string
    storage-acc = string
    create      = string
  }))
}
variable "vm-01-extension" {
  type = map(string)
}


## VM AUTO ##
variable "vm-test" {
  type = map(object({
    name               = string
    size               = string
    user               = string
    pass               = string
    pass-auth          = bool
    osdisk-cache       = string
    osdisk-storage-acc = string
    osdisk-size        = number
    image-publisher    = string
    image-offer        = string
    image-sku          = string
    image-version      = string
    nic-ip-name        = string
    nic-ip-type        = string
  }))
}
