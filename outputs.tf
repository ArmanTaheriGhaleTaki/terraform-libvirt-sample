# output "ips" {
#   description = "Map of VM names to interfaces and their IP addresses"
#   value = {
#     for vm_name, domain in libvirt_domain.domain_ubuntu :
#     vm_name => {
#       for iface in domain.network_interface :
#       iface.network_name => iface.addresses
#     }
#   }
# }
# To generate an actual SSH config file, add this:
resource "local_file" "ansible_inventory" {
  filename = "${path.root}/ssh_config"
  content  = templatefile("${path.module}/templates/ssh_config.tpl", {
    vms            = var.vms
    libvirt_domain = libvirt_domain.domain_ubuntu
    ifaces         = iface.network_name
  })  
}
