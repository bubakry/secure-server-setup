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

echo "Restarting SSH service..."

# Restart SSH service based on what's available
if systemctl list-units --type=service | grep -q "sshd.service"; then
  systemctl restart sshd.service
elif systemctl list-units --type=service | grep -q "ssh.service"; then
  systemctl restart ssh.service
elif systemctl list-units --type=socket | grep -q "ssh.socket"; then
  systemctl restart ssh.socket
elif service ssh status &>/dev/null; then
  service ssh restart
else
  echo "Could not find SSH service to restart. Please restart it manually."
  exit 1
fi

echo "SSH configured for key authentication only."
