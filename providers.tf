terraform {
#  required_version = "~> 1.10.5"
  required_version = "1.13.4"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    # template = {
    #   source  = "hashicorp/template"
    #   version = "~> v2.2.0"
    # }         
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}
