# Setting up a QEMU/KVM Virtual Machine with Libvirt using Terraform

This guide will help you set up a virtual machine using QEMU/KVM with libvirt through Terraform.

## Prerequisites
- Ubuntu 24.10 with QEMU, KVM, and libvirt installed
- Terraform v1.10.5 installed
- `terraform-provider-libvirt` ([dmacvicar/libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest)) plugin installed

## Quick Setup (Automated)

For a quick automated setup, you can use the provided script:

```sh
# Make the script executable
chmod +x script/setup-libvirt.sh

# Run the automated setup
./script/setup-libvirt.sh
```

This script will:
- Install QEMU/KVM and libvirt packages
- Create and configure the default storage pool
- Set proper permissions
- Add your user to the libvirt group
- Download and prepare the Ubuntu Cloud image
- Provide the absolute path to use in your Terraform configuration

After running the script, log out and log back in for group membership changes to take effect.

## Manual Configuration Steps

If you prefer to set up everything manually, follow these steps:

### 1. Enable Libvirt and Adjust Permissions
To avoid permission denied errors when using Terraform with libvirt, modify the `/etc/libvirt/qemu.conf` file:

```sh
sudo nano /etc/libvirt/qemu.conf
```

Find the following line:

```sh
# security_driver = "selinux"
```

Change it to:

```sh
security_driver = "none"
```

Then restart libvirt:

```sh
sudo systemctl restart libvirtd
```

### 2. Clone Terraform Configuration Repository
If you have a predefined Terraform configuration, clone the repository:

```sh
git clone https://github.com/ArmanTaheriGhaleTaki/terraform-libvirt-sample.git
cd terraform-libvirt-sample
```

### 3. Initialize Terraform
Run the following command to initialize the Terraform working directory:

```sh
terraform init
```

### 4. Validate and Plan
Before applying the configuration, validate and check the execution plan:

```sh
terraform validate
terraform plan
```

### 5. Apply the Terraform Configuration
Once validated, apply the configuration to create the virtual machine:

```sh
terraform apply -auto-approve
```

### 6. Modify Cloud-Init Configuration
To customize your VM’s initialization process, update the Cloud-Init configuration according to your needs. Modify user-data and meta-data files accordingly.

### ⚠️⚠️ Static IP Issue ⚠️⚠️
If you configure a static IP for the VM, Terraform will not terminate successfully and will keep retrying endlessly. However, this is expected behavior, and you can safely interrupt the process and SSH into the server manually without issues.

###  Destroy the VM 
If you need to remove the VM, use:

```sh
terraform destroy -auto-approve
```
## Using Terragrunt

This project supports Terragrunt for managing environment-specific VM configurations without modifying the Terraform module itself.

### Directory Structure

```text
vms/
└── sample/
    └── terragrunt.hcl
```

### Example `vms/sample/terragrunt.hcl`

```hcl
terraform {
  source = "../.."
}

inputs = {

  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF1OrLR5yBv12vEGheLIpNvFCmZhkW7d0//y4kuCnNO arman",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCboU9K2OnqijQe9ZYb4HkfHh/98gtRPQpAnY4sIxD1yYQXEKKPuGJYo/Pe3smoCQCxKwGtiyGO+yS8t137VItGxk31jTmlvRn+RJrtQUNIejcgMUpJVQfW901nCPc7jiTGJg+fQUZjJ0Tjg/RB7mty9AXELTPbV1YepXcAta/+VXUxEpNTyIpIRJwFQzmbCMXqHAmupwxiyu+6mieRUj5/GR2BeWxINWHhnNrbgObKcIhCqJ9hb2Ekh1dDAiRBZ8L0VWUSh0cMHJoZ34ZqLd63U3zzqtAAB6sRzKLiMKEO99rjLOWyAkxcNoMYEss6DIUoTMLkUn1EXDn3RUhaMgfaH5UlgkTOr7MFaIJcLbDkSN4SaveRdq+Aq6nTQUBZ1YaT+rIL7vBXfPcV94pG0ySm5t7nFgDVpNdjCHsrhLL6HTlx27llxkDZ2pK/0k3D3xDdwNE/1SaZTPHqOOHFuW+1mfl2qlMzXYYyALOwG4lQQkql2NaLlEoUM3dFHM9x9x8= armon"
  ]

  "root_password"= 123123

  network_config = {
    name       = "airgap"
    autostart  = true
    mode       = "none"
    domain     = "armondy.ir"
    addresses  = ["10.200.12.0/24"]
    dns_hosts = [
      { hostname = "bemula", ip = "85.85.85.85" },
      { hostname = "web1", ip = "10.198.12.10" },
      { hostname = "web2", ip = "10.198.12.11" },
      { hostname = "test", ip = "10.198.12.11" }
    ]
  }

  vms = {
      "test01" = {
    vm_hostname = "test01"
    memory      = 4
    vcpu        = 4
    disk        = 30
    networks = [
      { network_name = "airgap" },
      { network_name = "default" }
    ]
    },
      "test02" = {
    vm_hostname = "test02"
    memory      = 4
    vcpu        = 4
    disk        = 30
    networks = [
      { network_name = "airgap" }
    ]
    },
      "test03" = {
    vm_hostname = "test03"
    memory      = 4
    vcpu        = 4
    disk        = 30
    networks = [
      { network_name = "airgap" }
    ]
    }
  }
}
```

### Initialize

```bash
cd vms/sample
terragrunt init
```

### Validate

```bash
terragrunt validate
terragrunt plan
```

### Deploy

```bash
terragrunt apply -auto-approve
```

### Destroy

```bash
terragrunt destroy -auto-approve
```

### Why Terragrunt?

Terragrunt allows you to keep the Terraform module generic while defining VM inventories, network settings, SSH keys, and environment-specific configurations in separate `terragrunt.hcl` files. This makes it easier to manage multiple VM environments using the same Terraform codebase.

## Setup Script

The repository includes an automated setup script (`script/setup-libvirt.sh`) that handles the initial configuration of your system for libvirt and QEMU/KVM. This script:

- **Installs Dependencies**: Automatically installs `qemu-kvm`, `libvirt-daemon-system`, and `virt-manager`
- **Configures Storage Pool**: Creates and configures the default storage pool at `/var/lib/libvirt/images/default`
- **Sets Permissions**: Ensures proper ownership and permissions for the storage pool
- **Downloads Cloud Image**: Downloads the Ubuntu Jammy (22.04) cloud image and resizes it by +50G
- **User Configuration**: Adds your user to the libvirt group for proper access

The script provides the absolute path of the downloaded image, which you can use directly in your `variables.tf` file.

## Acknowledgment
Special thanks to **Molla Salehi** (GitHub: [mm3906078](https://github.com/mm3906078)) for contributions and guidance.


