resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  vm_id       = var.vm_id
  node_name   = var.node_name
  tags        = var.tags
  description = "Managed by Terraform - devops-proxmox-project"

  on_boot = true
  started = true

  clone {
    vm_id        = var.template_vm_id
    node_name    = var.template_node
    datastore_id = var.datastore_id
    full         = true
  }

  # Template has no qemu-guest-agent installed; enabling it here would make
  # Terraform wait for an agent that never answers. Ansible can add it later.
  agent {
    enabled = false
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
  }

  # Same interface as the template's disk, so the cloned disk is resized
  # instead of a second disk being added.
  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_gb
    discard      = "on"
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  # Ubuntu cloud images use a serial console (matches the template)
  serial_device {}
  vga {
    type = "serial0"
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = "${var.ip}/${var.prefix_length}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.ssh_user
      keys     = var.ssh_public_keys
    }
  }
}
