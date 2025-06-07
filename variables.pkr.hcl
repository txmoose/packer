variable "proxmox_api_url" {
  type    = string
  default = "https://hive.lan:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "kyle@authentik!packer" # Replace with your Proxmox API token ID
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
