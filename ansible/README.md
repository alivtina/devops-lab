# Ansible Web Server Automation

This project demonstrates basic Ansible automation for configuring an Ubuntu web server.

## Goal

Automate the setup and management of a web server using Ansible instead of configuring the server manually.

## Environment

* **Control node:** Arch Linux
* **Managed node:** Ubuntu Server VM
* **Virtualization:** QEMU/KVM + libvirt
* **Automation:** Ansible
* **Web server:** Nginx
* **Application:** Python HTTP server
* **Service manager:** systemd

## What the Playbook Does

The playbook:

1. Installs Nginx.
2. Creates the application directory.
3. Creates a simple HTML page.
4. Creates a systemd service for the Python HTTP server.
5. Reloads systemd when the service definition changes.
6. Starts and enables the Python application service.
7. Starts and enables Nginx.

The Python application listens on port `8000`, while Nginx listens on port `80` and forwards requests to the Python application.

## Architecture

```text
Arch Linux host
      │
      │ SSH
      ▼
Ubuntu Server VM
      │
      ├── Nginx :80
      │      │
      │      ▼
      │   Python HTTP server :8000
      │
      └── systemd
```

## Ansible Concepts Practiced

This project demonstrates:

* Inventory configuration
* SSH connectivity
* Privilege escalation (`become`)
* Ansible modules
* `apt`
* `file`
* `copy`
* `systemd_service`
* Service management
* Handlers
* Variables
* Idempotency
* Configuration drift correction

## Handlers

The systemd service file uses a handler:

```yaml
notify:
  - Reload systemd
```

The handler runs only when the service configuration changes.

This avoids unnecessarily reloading systemd on every playbook execution.

## Idempotency

The playbook was executed multiple times.

After the desired configuration was already present, Ansible reported:

```text
changed=0
```

This demonstrates idempotent configuration management: running the same playbook repeatedly does not make unnecessary changes.

## Troubleshooting Exercise

During development, Nginx returned:

```text
502 Bad Gateway
```

The troubleshooting process was:

1. Check Nginx status.
2. Inspect the Nginx configuration.
3. Check listening ports with `ss`.
4. Test the upstream directly with `curl`.
5. Inspect the Nginx error log.
6. Identify that nothing was listening on port `8000`.
7. Start the Python backend.
8. Verify the complete request path.

The final request flow was:

```text
Client
  ↓
Ubuntu:80
  ↓
Nginx
  ↓
127.0.0.1:8000
  ↓
Python HTTP server
```

## Configuration

A sanitized inventory example is provided:

```text
inventory.ini.example
```

Copy it to `inventory.ini` and replace the placeholders with your own server details.

The real inventory is excluded from Git.

## Run

After configuring the inventory:

```bash
ansible-playbook -i inventory.ini playbook.yml --ask-pass --ask-become-pass
```

Check the web server:

```bash
curl http://YOUR_SERVER_IP
```

Check the Python service:

```bash
systemctl status python-http
```

## What This Project Demonstrates

This project demonstrates practical experience with:

* Linux server administration
* SSH
* Nginx
* systemd
* Python services
* Ansible automation
* Infrastructure troubleshooting
* Idempotent configuration management

It is part of a larger hands-on DevOps learning lab covering Linux, networking, Git, Docker, CI/CD, Terraform, and Ansible.
