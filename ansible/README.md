# Ansible Web Server Automation

A hands-on Ansible project demonstrating automated configuration and management of an Ubuntu web server.

The project replaces manual server configuration with a reproducible Ansible playbook that installs services, creates application files, manages systemd, and configures a working Nginx → Python web application stack.

## Goal

Automate the setup and management of a Linux web server using Ansible instead of configuring each component manually.

The project focuses on practical configuration management concepts such as:

* SSH-based remote administration
* privilege escalation
* Ansible modules
* service management
* handlers
* idempotency
* configuration drift correction
* troubleshooting

## Environment

* **Control node:** Arch Linux
* **Managed node:** Ubuntu Server VM
* **Virtualization:** QEMU/KVM + libvirt
* **Automation:** Ansible
* **Web server:** Nginx
* **Backend:** Python HTTP server
* **Service manager:** systemd

## Architecture

```text
Arch Linux host
      │
      │ Ansible over SSH
      ▼
Ubuntu Server VM
      │
      ├── Nginx :80
      │      │
      │      │ reverse proxy
      │      ▼
      │   Python HTTP server :8000
      │
      └── systemd
             └── python-http.service
```

The client connects to Nginx on port `80`.

Nginx forwards the request to the Python HTTP server listening on port `8000`.

The Python application is managed as a systemd service.

## What the Playbook Does

The playbook:

1. Installs Nginx.
2. Creates the application directory.
3. Creates the web content.
4. Creates a systemd service for the Python HTTP server.
5. Reloads systemd when the service definition changes.
6. Starts and enables the Python application service.
7. Starts and enables Nginx.

This allows the server to be configured from a single reproducible playbook instead of performing each step manually.

## Ansible Concepts Practiced

This project demonstrates:

* inventory configuration
* SSH connectivity
* privilege escalation with `become`
* Ansible modules
* `apt`
* `file`
* `copy`
* `systemd_service`
* service management
* handlers
* variables
* idempotency
* configuration drift correction

## Handlers

The systemd service definition uses a handler:

```yaml
notify:
  - Reload systemd
```

The handler runs only when the service configuration changes.

This avoids unnecessarily reloading systemd when the playbook is executed without configuration changes.

## Idempotency

The playbook was executed multiple times.

After the desired configuration was already present, Ansible reported:

```text
changed=0
```

This demonstrates **idempotent configuration management**: repeatedly applying the same desired configuration does not cause unnecessary changes.

This is one of the key advantages of configuration-management tools such as Ansible.

## Troubleshooting Exercise

During development, Nginx returned:

```text
502 Bad Gateway
```

Instead of immediately changing the configuration, the problem was investigated using the available evidence:

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

This exercise demonstrates a practical troubleshooting approach: **observe → collect evidence → identify the failing component → fix → verify**.

## Configuration

A sanitized inventory template is provided:

```text
inventory.ini.example
```

Copy it to a local inventory file:

```bash
cp inventory.ini.example inventory.ini
```

Then replace the placeholders with the details of your own managed server.

The real `inventory.ini` file is excluded from Git.

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

You can also verify that the expected ports are listening:

```bash
ss -lntp
```

## Expected Result

After successful execution:

* Nginx is installed and running.
* The Python backend is running as a systemd service.
* The Python backend listens on port `8000`.
* Nginx listens on port `80`.
* Requests to Nginx are forwarded to the Python backend.
* Re-running the playbook does not produce unnecessary changes.

## What This Project Demonstrates

This project demonstrates practical experience with:

* Linux server administration
* SSH
* Nginx
* systemd
* Python services
* Ansible automation
* configuration management
* idempotency
* infrastructure troubleshooting

It is part of a larger hands-on DevOps laboratory covering Linux, networking, Git, Docker, CI/CD, Terraform, Kubernetes, Helm, monitoring, and Ansible.
