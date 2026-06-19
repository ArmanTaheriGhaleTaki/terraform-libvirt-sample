%{ for vm_name, vm in vms ~}
%{ for iface in domains[vm_name].network_interface ~}
Host kvm-${vm.vm_hostname}-${iface.network_name}
    HostName ${iface.addresses[0]}
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
%{ endfor ~}
%{ endfor ~}