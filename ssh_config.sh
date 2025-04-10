#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo or as root."
  exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"

echo "Removing existing PasswordAuthentication and PubkeyAuthentication lines..."
sed -i '/^PasswordAuthentication/d' "$SSHD_CONFIG" || { echo "Failed to clean PasswordAuthentication"; exit 1; }
sed -i '/^PubkeyAuthentication/d' "$SSHD_CONFIG" || { echo "Failed to clean PubkeyAuthentication"; exit 1; }

echo "Enforcing SSH key authentication..."
echo "PasswordAuthentication no" >> "$SSHD_CONFIG" || { echo "Failed to add PasswordAuthentication setting"; exit 1; }
echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG" || { echo "Failed to add PubkeyAuthentication setting"; exit 1; }

systemctl restart sshd || { echo "Failed to restart SSH"; exit 1; }

echo "SSH configured for key authentication only."
