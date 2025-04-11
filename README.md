# Technical Enhancements for Network Security Policy Development

This repository contains configuration scripts and resources used to simulate and enforce a network security policy in a virtualized environment.

---

##  Project Objective

Create a virtual network using tools like VirtualBox, VMware, or GNS3 to simulate an organization’s infrastructure and demonstrate the enforcement of key security policies.

###  Components
- **Virtual Machines**: All VMs are Linux distributions (e.g., Ubuntu for servers and workstations)
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
- Drops all traffic by default
- Allows only:
  - SSH & ping from a specified admin IP
  - Responses to SSH and ping from that IP
- Logs unauthorized access attempts

**Usage:**
```bash
sudo ./iptables.sh <ADMIN_WORKSTATION_IP>
```

---

### `ssh_config.sh`
Hardens SSH by enforcing key-based authentication and disabling password login.

**Usage:**
```bash
sudo ./ssh_config.sh
```

---

### `install.sh`
Combines `iptables.sh` and `ssh_config.sh` to secure the server in one step.

**Usage:**
```bash
sudo ./install.sh <ADMIN_WORKSTATION_IP>
```

---

##  Lab Setup Tips

To simulate and enforce network security policies, follow these guidelines when setting up your test environment:

###  Virtual Machine Setup
- Use **VirtualBox**, **VMware**, or **GNS3** to create isolated virtual machines.
- Suggested VM roles:
  - **Ubuntu Server** — acts as the target machine to be hardened.
  - **Other Linux-based Workstation(s)** — used to validate unauthorized access attempts.
  - **Admin Workstation (Ubuntu)** — from which secure SSH access is tested.

###  Networking Configuration
- Use **host-only** or **internal networking** for safe, isolated testing.
- - Static IP assignment is optional; DHCP within the internal network is acceptable. For example:
  - Admin Workstation: `192.168.65.5`
  - Ubuntu Server: `192.168.65.10`

###  SSH Key Setup
On the admin workstation:
```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id user@192.168.65.10
```

Verify passwordless SSH access works before running the hardening scripts.

###  Testing the Security Policy
- Try SSH access from:
  - Admin workstation (should succeed)
  - Any other machine (should fail)
- Use `ping` and `nmap` to validate firewall behavior:
  ```bash
  ping 192.168.65.10
  nmap -Pn -p 22 192.168.65.10
  ```
- Attempt to SSH with a password after hardening (should be rejected).


