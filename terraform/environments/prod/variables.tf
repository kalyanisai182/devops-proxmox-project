variable "proxmox_endpoint" {
  description = "Proxmox API URL, e.g. https://10.30.4.76:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token in the form user@realm!tokenid=secret"
  type        = string
  sensitive   = true
}
