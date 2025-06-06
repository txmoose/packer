# Packer Ubuntu 24.04 Proxmox Template

This repository contains a [Packer](https://www.packer.io/) configuration for building an automated Ubuntu Server 24.04 (Noble) template for [Proxmox VE](https://www.proxmox.com/proxmox-ve).  
It leverages Ubuntu's autoinstall and cloud-init for fully unattended provisioning, and includes post-processing steps to prepare the image for use as a Proxmox VM template.

## Features

- Automated Ubuntu 24.04 installation using autoinstall and cloud-init
- Proxmox ISO build integration
- Cloud-init and QEMU guest agent support
- Secure SSH key-based access for provisioning
- Post-install cleanup and template optimization
- Custom CA certificate and cloud-init configuration injection

## Credits

> **Note:**  
> This repository is heavily based on templates from [Christian Lempa](https://github.com/ChristianLempa/boilerplates/tree/main).