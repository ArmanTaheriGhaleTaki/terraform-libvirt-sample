${join("\n", [
  for name, vm in vms : "host ${vm.vm_hostname}\nhostname ${lookup(libvirt_domain, name).network_interface[0].addresses[0]}\nuser root"
])}
