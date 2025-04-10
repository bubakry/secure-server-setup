#!/bin/bash
# script to configure iptables for a high-security isolated server
# use case: Sensitive data repository accessible only by admin workstation

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo or as root."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Error: No admin IP provided."
  echo "Please specify the admin workstation IP as a command-line argument."
  exit 1
else
  ADMIN_IP="$1"
fi

if ! [[ "$ADMIN_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: '$ADMIN_IP' is not a valid IP address."
  exit 1
fi

echo "Configuring firewall for admin IP: $ADMIN_IP..."

# clear existing rules across all tables
echo "Clearing existing iptables rules..."
iptables -F || { echo "Failed to flush rules"; exit 1; }
iptables -F -t nat || { echo "Failed to flush nat table"; exit 1; }
iptables -F -t mangle || { echo "Failed to flush mangle table"; exit 1; }

# set default policies to DROP
echo "Setting default policies to DROP..."
iptables -P INPUT DROP || { echo "Failed to set INPUT policy"; exit 1; }
iptables -P OUTPUT DROP || { echo "Failed to set OUTPUT policy"; exit 1; }
iptables -P FORWARD DROP || { echo "Failed to set FORWARD policy"; exit 1; }

# allow established and related incoming traffic (for SSH sessions)
echo "Allowing established and related incoming traffic..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT || { echo "Failed to set INPUT ESTABLISHED,RELATED rule"; exit 1; }

# allow new SSH connections from admin workstation
echo "Allowing SSH from $ADMIN_IP..."
iptables -A INPUT -p tcp --dport 22 -s "$ADMIN_IP" -m state --state NEW -j ACCEPT || { echo "Failed to set SSH INPUT rule"; exit 1; }

# allow ping requests from admin workstation
echo "Allowing ping from $ADMIN_IP..."
iptables -A INPUT -p icmp --icmp-type echo-request -s "$ADMIN_IP" -j ACCEPT || { echo "Failed to set ping INPUT rule"; exit 1; }

# allow SSH responses to admin workstation
echo "Allowing SSH responses to $ADMIN_IP..."
iptables -A OUTPUT -p tcp --sport 22 -d "$ADMIN_IP" -m state --state NEW,ESTABLISHED -j ACCEPT || { echo "Failed to set SSH OUTPUT rule"; exit 1; }

# allow ping replies to admin workstation
echo "Allowing ping replies to $ADMIN_IP..."
iptables -A OUTPUT -p icmp --icmp-type echo-reply -d "$ADMIN_IP" -j ACCEPT || { echo "Failed to set ping OUTPUT rule"; exit 1; }

# log blocked incoming traffic
echo "Setting up logging for blocked incoming traffic..."
iptables -A INPUT -j LOG --log-prefix "IPTables-Blocked: " --log-level 4 || { echo "Failed to set logging rule"; exit 1; }

echo "Firewall configuration complete for admin IP: $ADMIN_IP!"
