locals {
  # ---------- Settings common to every VM in this environment ----------
  node_name      = "R2S09"
  template_vm_id = 9000
  template_node  = "R2S16"
  datastore_id   = "ceph-rbd-storage"
  gateway        = "10.30.5.251" # subnet gateway (from MAAS)
  dns_servers    = ["10.30.4.252", "1.1.1.1"]
  ssh_keys       = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]

  # ---------- The VMs: keyed by name, so the key is each VM's identity ----------
  # VM IDs are not set here: Proxmox assigns the next free ID.
  vms = {
    jenkins = {
      ip        = "10.30.5.55"
      cores     = 2
      memory_mb = 4096
      disk_gb   = 30
    }
    sonarqube = {
      ip        = "10.30.5.56"
      cores     = 2
      memory_mb = 4096
      disk_gb   = 30
    }
  }
}

module "vm" {
  source   = "../../modules/proxmox-vm"
  for_each = local.vms

  name      = each.key
  node_name = local.node_name
  tags      = ["devops-project", "shared"]

  template_vm_id = local.template_vm_id
  template_node  = local.template_node

  cores        = each.value.cores
  memory_mb    = each.value.memory_mb
  disk_gb      = each.value.disk_gb
  datastore_id = local.datastore_id

  ip              = each.value.ip
  gateway         = local.gateway
  dns_servers     = local.dns_servers
  ssh_public_keys = local.ssh_keys
}

output "vms" {
  description = "VMs created in the shared environment"
  value = {
    for name, vm in module.vm : name => {
      vm_id = vm.vm_id
      ip    = vm.ip
    }
  }
}
