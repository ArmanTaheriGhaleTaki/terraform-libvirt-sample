##TODO: add nwfilter clean-traffic

resource "libvirt_network" "internal" {
  name       = var.network_config.name
  autostart  = var.network_config.autostart
  mode       = var.network_config.mode
  domain     = var.network_config.domain
  addresses  = var.network_config.addresses

  dns {
    enabled    = true
    local_only = true
    dynamic "hosts" {
      for_each = var.network_config.dns_hosts
      content {
        hostname = hosts.value.hostname
        ip       = hosts.value.ip
      }
    }
  }
  dnsmasq_options {
    # (Optional) one or more option entries.
    # "option_name" muast be specified while "option_value" is
    # optional to also support value-less options.  The format is:
    # options  {
    #     option_name = "server"
    #     option_value = "/base.domain/my.ip.address.1"
    #   }
    # options  {
    #     option_name = "no-hosts"
    #   }
    # options {
    #     option_name = "address"
    #     ip = "/.api.base.domain/my.ip.address.2"
    #   }
    #
  }
}
