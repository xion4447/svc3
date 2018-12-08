# Configure the Microsoft Azure Provider
provider "azurerm" 

{
    #charlie
    #subscription_id = "724db8b9-5413-4f32-a268-df91eb327608"
    #tenant_id       = "8a3e6369-36e7-4b9a-8db6-a8f0154c7ee8"
    
    #anne
    #subscription_id = "47dd0b57-897b-4d46-a91f-7ab52dec905b"
    #tenant_id       = "a081ff79-318c-45ec-95f3-38ebc2801472"
    
    #khilesh
    #subscription_id = "221939ed-a3dd-4825-ac1e-063b766c2895"
    #tenant_id       = "a081ff79-318c-45ec-95f3-38ebc2801472"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"


    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "html"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "49160"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            #charlie
            #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfw6nbvbs9rfnjbE1wYrIyowRV7mJJ7Tan8AkbM3eozZkW6p0xi01IXip1PqIZknYtBh67JoMkDs9Utt3Kd9dPYyxX6vvOU83ifTMgH5frtQho1CAdfa9T0hf62zdZ2ikxLaTPSrW1YgwJ8SvJZRBvULDfU5Rw4ydi3vncF3AbzTBnA/2asigGE1vHT2SHBsQtDkzpVE90vWECSCUbiGXTIKybI4G4ITLH7XtK9RUoMwTeOiPU6rq9bQtaAXVY8SyS7+d0EGEaL76hxLWCTBFvGlv/ZvzgJrSuxwPP5Wk7DO9XmNInwdxQcWZUj+Q6ayQIsOtMLWAGL8Qm/G/cbgY1 betz4871@cc-634c241-7b979cb95f-5mvdh"
            #anne
            #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRiwitEJE0EhYw5Ok+oE2/cUMD22KNKHoouDfKGoTlA4Ggxs9LdQQtA1qsOe66fDfBcR9u9y9nwVXP5P88d+oimBuSEO9G6NjYyIPMm83q6uf4ugrAmgTfFAhyyGcdGFUSPt/w9rFmK4dHHcKVJTDnbHlgYj4L1PTUpclyoiPUnRoWS0qkW3r7lLu/mo4iMsirq+1eMFoUSZjUgqH/n7Re54fh9o+N+h6U7j7t+FnxH4Zib9neh5jLMrpQm1dVWUGzRE1Rl6v1em0wP1E9YCwlmHet+GSkU3iIY4k/4NFWKAnY6byYQ3ArcY+Ysh8vWbh0m1ETfhts1SA4E+idu0N/ wort7856@cc-980dd03b-688f64498b-5h9dk"
            #khilesh
            #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDt0rFvjZ9Sa82oK0BIQKyZ4yxdTSl2qt8nqAl0FP5l/QbdV0WxhFQPijR0bXh0B2tedtTThGsf1rYK1MjeotwIatZe/rf8gMFnhyADw4l1+AIbXSkut5dGY8cuBSrtgCArpXJgQMcGh0t1kWbAMk2q3AYWDbShELeL2tdNKQ/ElBijyVYfvNSjRD/xncnniKXytenD0KLdXn8y8aGU7khUjIP0ympIQ+ydUpQFfeFcnFk1O96TkM6LxYXXdgVr2xThN3xwHe8d+2IhNgF/up3E8m3PWypo3LlJ7dlIUVoIvp+pDxQI41EBQBNauXjkQ33kAeXxjQ1O9OZ3KWOfCpzL nagr6052@cc-d7c283b5-8c5bd4c8-m7kmk"
            }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }

connection {
        user = "azureuser"
        private_key = "${file("~/.ssh/id_rsa")}"
    }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y install docker.io",
      "mkdir svc3"
     ]
  }
  
  provisioner "file" {
     source = "."
     destination = "/home/azureuser/svc3"
  }
  
  provisioner "remote-exec" {
    inline = [
      "cd svc3",
      "chmod +x *.sh",
      "sudo ./build.sh",
      "sudo ./run.sh"
      #"curl localhost:49160"  
     ]
  }

}
