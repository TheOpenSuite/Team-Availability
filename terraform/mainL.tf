terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "hmis_os_volume" {
  name   = var.volume_name
  source = var.image_source_path
}

resource "libvirt_cloudinit_template" "commoninit" {
  name      = var.cloudinit_name
  user_data = <<-EOT
    #cloud-config
    hostname: ${var.hostname}
    manage_etc_hosts: true
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${file(var.ssh_public_key_path)}
  EOT
}

resource "libvirt_domain" "hmis_vm" {
  name   = var.hostname
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.hmis_os_volume.id
  }

  cloudinit = libvirt_cloudinit_template.commoninit.id

  provisioner "local-exec" {
    command = "while ! ip a | grep -q ${self.name}; do sleep 2; done"
  }
}
