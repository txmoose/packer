variable "proxmox_api_url" {
  type    = string
  default = "https://proxmox:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "your-proxmox-api-token-id" # Replace with your Proxmox API token ID
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
