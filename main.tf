data "template_file" "user_data" {
  for_each = var.vms

  template = file("${path.module}/config/cloud-init.tpl.yml")

  vars = {
    vm_hostname  = each.value.vm_hostname
    domain       = var.network_config.domain
    root_password = var.root_password
    ssh_keys       = join("\n  - ", var.ssh_keys)
  }
}
data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

# Create a disk for each VM
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base"
  source = var.ubuntu_24_img_url
  pool   = "default"
  format = "qcow2"
}
resource "libvirt_volume" "vm_disks" {
  for_each = var.vms

  name   = "${each.key}-ubuntu-disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool   = "default"
  size           = each.value.disk * 1024 * 1024 * 1024
}

# Create a VM (domain) for each VM configuration
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = var.vms

  name           = "${each.key}-commoninit.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config.rendered
}

# Create a VM (domain) for each VM configuration
resource "libvirt_domain" "domain_ubuntu" {
  for_each = var.vms

  name   = each.value.vm_hostname
  memory = each.value.memory * 1024
  vcpu   = each.value.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id
dynamic "network_interface" {
  for_each = each.value.networks
  content {
    network_name    = network_interface.value.network_name
    wait_for_lease  = true
    mac             = lookup(network_interface.value, "mac", null)
    bridge          = lookup(network_interface.value, "bridge", null)
    hostname        = each.value.vm_hostname
    #TODO: nedd to contributed into
    #https://github.com/dmacvicar/terraform-provider-libvirt
    # nwfilter     = "clean-traffic"
    # nwfilter not supported in Terraform libvirt provider
  }
}
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.vm_disks[each.key].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
  # autostart = true
}
