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
    domain     = "test.com"
    addresses  = ["10.200.12.0/24"]
    dns_hosts = [
      { hostname = "test01", ip = "85.85.85.85" },
      { hostname = "web1", ip = "10.200.12.10" },
      { hostname = "web2", ip = "10.200.12.11" },
      { hostname = "test", ip = "10.200.12.11" }
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
