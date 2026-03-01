# AI Agent Instructions for Terraform LibVirt Project

## Project Overview
This project provides Infrastructure as Code (IaC) templates for creating and managing QEMU/KVM virtual machines using Terraform with the LibVirt provider. The codebase follows a modular structure for managing multiple VMs with customizable configurations.

## Key Components and Architecture

### Core Files
- `main.tf`: Central configuration file managing VM resources
- `internal-network.tf`: Network configuration and DNS settings
- `config/cloud-init.tpl.yml`: VM initialization template
- `variables.tf`: Project-wide variable definitions
- `outputs.tf`: Resource output definitions

### Design Patterns
1. **Resource Templating**: Uses Terraform's `for_each` to create multiple VMs from a single configuration block
   ```hcl
   resource "libvirt_domain" "domain_ubuntu" {
     for_each = var.vms
     name   = each.value.vm_hostname
     # ...
   }
   ```

2. **Network Configuration**: Implements internal networks with DNS management
   - See `internal-network.tf` for network resource definitions
   - Uses `dnsmasq_options` for advanced DNS configuration

3. **Cloud-Init Integration**: Automated VM initialization using cloud-init
   - Template: `config/cloud-init.tpl.yml`
   - Supports SSH key injection and package installation

## Critical Workflows

### Setup Requirements
1. Prerequisites:
   - QEMU/KVM and libvirt installed
   - Terraform v1.10.5+
   - terraform-provider-libvirt plugin

2. Initialize Project:
   ```bash
   terraform init
   terraform validate
   terraform plan
   ```

### Known Issues
- Static IP configuration may cause terraform apply to retry indefinitely (expected behavior)
- Root login permissions require specific cloud-init configuration

## Development Conventions

### Variable Structure
- VM configurations are defined as map objects in `terraform.tfvars`
- Network configurations follow the structure defined in `variables.tf`

### Resource Naming
- Use descriptive names for resources following the pattern: `<purpose>-<type>`
- Example: `ubuntu-base` for base image, `<vmname>-ubuntu-disk.qcow2` for VM disks

### Cloud-Init Templates
- Store all cloud-init templates in `config/` directory
- Use consistent variable interpolation: `${var_name}`

## Integration Points
- LibVirt Provider: Primary infrastructure provider
- Cloud-Init: VM initialization and configuration
- Ubuntu Cloud Images: Base image source
- Local LibVirt daemon: Resource management

For detailed setup instructions, refer to `README.md` or run the automated setup script in `script/setup-libvirt.sh`.