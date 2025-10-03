variable "ubuntu_24_img_url" {
  description = "Path or URL to the Ubuntu image"
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
variable "ssh_keys" {
  description = "List of authorized SSH public keys"
  type        = list(string)
  default = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF1OrLR5yBv12vEGheLIpNvFCmZhkW7d0//y4kuCnNO arman",
    # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCboU9K2OnqijQe9ZYb4HkfHh/98gtRPQpAnY4sIxD1yYQXEKKPuGJYo/Pe3smoCQCxKwGtiyGO+yS8t137VItGxk31jTmlvRn+RJrtQUNIejcgMUpJVQfW901nCPc7jiTGJg+fQUZjJ0Tjg/RB7mty9AXELTPbV1YepXcAta/+VXUxEpNTyIpIRJwFQzmbCMXqHAmupwxiyu+6mieRUj5/GR2BeWxINWHhnNrbgObKcIhCqJ9hb2Ekh1dDAiRBZ8L0VWUSh0cMHJoZ34ZqLd63U3zzqtAAB6sRzKLiMKEO99rjLOWyAkxcNoMYEss6DIUoTMLkUn1EXDn3RUhaMgfaH5UlgkTOr7MFaIJcLbDkSN4SaveRdq+Aq6nTQUBZ1YaT+rIL7vBXfPcV94pG0ySm5t7nFgDVpNdjCHsrhLL6HTlx27llxkDZ2pK/0k3D3xDdwNE/1SaZTPHqOOHFuW+1mfl2qlMzXYYyALOwG4lQQkql2NaLlEoUM3dFHM9x9x8= arman@DPO02041L",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCboU9K2OnqijQe9ZYb4HkfHh/98gtRPQpAnY4sIxD1yYQXEKKPuGJYo/Pe3smoCQCxKwGtiyGO+yS8t137VItGxk31jTmlvRn+RJrtQUNIejcgMUpJVQfW901nCPc7jiTGJg+fQUZjJ0Tjg/RB7mty9AXELTPbV1YepXcAta/+VXUxEpNTyIpIRJwFQzmbCMXqHAmupwxiyu+6mieRUj5/GR2BeWxINWHhnNrbgObKcIhCqJ9hb2Ekh1dDAiRBZ8L0VWUSh0cMHJoZ34ZqLd63U3zzqtAAB6sRzKLiMKEO99rjLOWyAkxcNoMYEss6DIUoTMLkUn1EXDn3RUhaMgfaH5UlgkTOr7MFaIJcLbDkSN4SaveRdq+Aq6nTQUBZ1YaT+rIL7vBXfPcV94pG0ySm5t7nFgDVpNdjCHsrhLL6HTlx27llxkDZ2pK/0k3D3xDdwNE/1SaZTPHqOOHFuW+1mfl2qlMzXYYyALOwG4lQQkql2NaLlEoUM3dFHM9x9x8= armon"
  ]
}
variable "root_password" {
  description = "Root password for VMs"
  type        = string
  default     = "123"
  sensitive   = true
}
variable "network_config" {
  description = "Configuration for the libvirt network"
  type = object({
    name       = string
    autostart  = bool
    mode       = string
    domain     = string
    addresses  = list(string)
    dns_hosts  = list(object({
      hostname = string
      ip       = string
    }))
  })
  default = {
    name      = "internal"
    autostart = true
    mode      = "none"
    domain    = "armon.ir"
    addresses = ["10.198.12.0/24"]
    dns_hosts = [
      { hostname = "bemula", ip = "85.85.85.85" },
      { hostname = "web1", ip = "10.198.12.10" },
      { hostname = "web2", ip = "10.198.12.11" },
      { hostname = "test", ip = "10.198.12.11" }
    ]
  }
}

variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    vm_hostname = string
    memory      = number #GB
    vcpu        = number
    disk        = number #GB
    networks    = list(object({
      network_name = string
      mac          = optional(string)
      bridge       = optional(string)
    }))
  }))
  default = {
    "vm1" = {
      vm_hostname = "vm1"
      memory      = 4
      vcpu        = 4
      disk        = 30
      networks = [
        { network_name = "internal" },
        { network_name = "default" }
      ]
    },
    "vm2" = {
      vm_hostname = "vm2"
      memory      = 10
      vcpu        = 4
      disk        = 15
      networks = [
        { network_name = "internal" }
      ]
    },
    "vm3" = {
      vm_hostname = "vm3"
      memory      = 2
      vcpu        = 2
      disk        = 15
      networks = [
      { network_name = "internal" }
    ]
    },
  }
}
