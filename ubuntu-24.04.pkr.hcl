# Ubuntu Server Noble (24.04.x)
# ---
# Packer Template to create an Ubuntu Server (Noble 24.04.x) on Proxmox

packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-noble" {

  insecure_skip_tls_verify = true

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  # insecure_skip_tls_verify = true

  # VM General Settings
  node                 = "hive"
  vm_id                = "1001"
  vm_name              = "tmpl-ubuntu-2404"
  template_name        = "tmpl-ubuntu-2404"
  template_description = "Ubuntu Server Noble Image"
  tags                 = ["template"]

  # VM OS Settings
  boot_iso {
    type             = "scsi"
    iso_file         = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
    unmount          = true
    iso_storage_pool = "local"
  }

  # VM CPU Type Settings
  cpu_type = "host" # Use the host CPU type for better performance

  # VM OS Type Settings
  os_type    = "l26" # Linux 2.6/3.x/4.x/5.x Kernel
  os_variant = "ubuntu24.04"

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "25G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }


  efi_config {
    efi_storage_pool  = "local-lvm"
    pre_enrolled_keys = true
    efi_format        = "raw"
    efi_type          = "4m"
  }

  # BIOS Settings
  bios = "ovmf"

  # VM CPU Settings
  cores = "2"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Random Number Generator Settings
  rng0 {
    source    = "/dev/urandom"
    max_bytes = 1024
    period    = 1000
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"
  cloud_init_disk_type    = "scsi"

  # PACKER Boot Commands
  boot         = "c"
  boot_wait    = "10s"
  communicator = "ssh"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  # Useful for debugging
  # Sometimes lag will require this
  # boot_key_interval = "500ms"


  # PACKER Autoinstall Settings
  http_directory = "http"

  # (Optional) Bind IP Address and Port
  # http_bind_address       = "0.0.0.0"
  # http_port_min           = 8802
  # http_port_max           = 8802

  ssh_username   = "kyle"
  ssh_agent_auth = true

  # Raise the timeout, when installation takes longer
  ssh_timeout = "30m"
  ssh_pty     = true
}

# Build Definition to create the VM Template
build {

  name    = "ubuntu-server-noble"
  sources = ["source.proxmox-iso.ubuntu-server-noble"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "file" {
    source      = "files/txmoose_chain.pem"
    destination = "/tmp/txmoose_chain.pem"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sudo mv /tmp/txmoose_chain.pem /usr/local/share/ca-certificates/txmoose_chain.crt",
      "sudo apt install -y ca-certificates",
      "sudo update-ca-certificates",
      "sudo sync"
    ]
  }
}
