# gophish-tf

## Overview
Terraform configuration to setup [Gophish](https://github.com/gophish/gophish) on a single EC2 instance inside a VPC on AWS

## Scripts
- [install_gophish.sh](scripts/install_gophish.sh): download and setup Gophish as a systemd service
- [start_gophish.sh](scripts/start_gophish.sh): start script in systemd, start Gophish with proper log files
- [install_le_cert.sh](scripts/install_le_cert.sh): setup TLS certificates with Let's Encrypt

## References
- <https://github.com/gophish/gophish>
- <https://github.com/gophish/gophish/issues/586>