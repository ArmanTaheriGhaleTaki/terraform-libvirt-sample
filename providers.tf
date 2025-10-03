terraform {
  required_version = "~> 1.10.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}
