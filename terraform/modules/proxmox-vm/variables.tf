# ---------- Identity ----------
variable "name" {
  description = "VM hostname, also used as the Proxmox VM name"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM_ID. Leave null to let Proxmox assign the next free ID"
  type        = number
  default     = null	
}

variable "node_name" {
  description = "Proxmox node the VM runs on"
  type        = string
}

variable "tags" {
  description = "Tags shown in the Proxmox UI"
  type        = list(string)
  default     = []
}

# ---------- Source template ----------
variable "template_vm_id" {
  description = "VM ID of the cloud-init template to clone"
  type        = number
}

variable "template_node" {
  description = "Node where the template lives"
  type        = string
}

# ---------- Sizing ----------
variable "cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 4096
}

variable "disk_gb" {
  type    = number
  default = 30
}

variable "datastore_id" {
  description = "Storage for the VM disk and cloud-init drive"
  type        = string
}

# ---------- Network ----------
variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "ip" {
  description = "Static IPv4 address, without prefix length"
  type        = string
}

variable "prefix_length" {
  type    = number
  default = 24
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

# ---------- Access ----------
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_keys" {
  description = "Public keys injected by cloud-init for ssh_user"
  type        = list(string)
}
