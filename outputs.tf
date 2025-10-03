output "ips" {
  description = "Map of VM names to interfaces and their IP addresses"
  value = {
    for vm_name, domain in libvirt_domain.domain_ubuntu :
    vm_name => {
      for iface in domain.network_interface :
      iface.network_name => iface.addresses
    }
  }
}
