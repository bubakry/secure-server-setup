# Technical Enhancements for Network Security Policy Development

This repository contains configuration scripts and resources used to simulate and enforce a network security policy in a virtualized environment.

##  Project Objective

Create a virtual network using tools like VirtualBox, VMware, or GNS3 to simulate an organization’s infrastructure and demonstrate the enforcement of key security policies.

### Components:
- **Virtual Machines**: Ubuntu (for servers), Windows (for workstations)
- **Network Setup**: Static IPs, custom routing, DNS settings
- **Security Policies Enforced**:
  - SSH key-based authentication only
  - Restricting inbound traffic using `iptables`
  - Enforcing complex password rules
  - Blocking all ports except explicitly allowed ones (like SSH from admin IP)

---

##  Scripts

### `iptables.sh`
Configures firewall rules using `iptables`:
- Drops all by default
- Only allows SSH & ping from specified admin IP
- Logs unauthorized access attempts

```bash
sudo ./iptables.sh <ADMIN_WORKSTATION_IP>
