#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root or with sudo."
  exit 1
fi

# Check for admin IP argument
if [ -z "$1" ]; then
  echo "Usage: sudo ./install.sh <ADMIN_WORKSTATION_IP>"
  exit 1
fi

ADMIN_IP="$1"

# Run the firewall script
./iptables.sh "$ADMIN_IP" || { echo "iptables.sh failed"; exit 1; }

# Run the SSH config script
./ssh_config.sh || { echo "ssh_config.sh failed"; exit 1; }

echo "Secure server setup complete."

