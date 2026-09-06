# DevOps Lab

Hands-on DevOps practice environment covering Linux administration, networking, Bash scripting, Python, Git/GitHub, Docker, CI/CD, Terraform, Ansible, and virtualization.

The projects are built and tested using an Ubuntu Server virtual machine running on a QEMU/KVM environment with an Arch Linux host.

## Skills Demonstrated

| Area                     | Technologies / Skills                                                                                 |
| ------------------------ | ----------------------------------------------------------------------------------------------------- |
| Linux                    | Ubuntu Server, Arch Linux, CLI, package management, permissions, processes, services, troubleshooting |
| Networking               | TCP/IP, IP addresses, ports, localhost, NAT, SSH, `curl`, `ss`, `tcpdump`                             |
| Shell                    | Bash scripting, ShellCheck, command-line automation                                                   |
| Programming              | Python, pytest                                                                                        |
| Version Control          | Git, GitHub                                                                                           |
| Containers               | Docker, Docker Compose, Dockerfiles, non-root containers, health checks                               |
| CI/CD                    | GitHub Actions, automated testing, Docker builds, artifacts, deployment                               |
| Infrastructure as Code   | Terraform, Docker provider, resources, variables, outputs, state                                      |
| Configuration Management | Ansible, inventory, modules, privilege escalation, handlers, idempotency                              |
| Virtualization           | QEMU/KVM, libvirt, virt-manager, VirtualBox                                                           |

## Repository Structure

```text
devops-lab/
├── .github/
│   └── workflows/
│       └── ci.yml
├── ansible/
│   ├── README.md
│   ├── ansible.cfg
│   ├── inventory.ini.example
│   └── playbook.yml
├── docker/
│   ├── app-demo/
│   ├── compose-demo/
│   ├── dockerfile-demo/
│   ├── website/
│   └── README.md
├── python/
│   └── system-health/
│       ├── Dockerfile
│       ├── README.md
│       ├── requirements.txt
│       └── system.py
├── scripts/
├── terraform/
│   ├── first-project/
│   │   └── README.md
│   └── web-infrastructure/
│       └── README.md
├── tests/
├── troubleshooting/
├── .dockerignore
├── .gitignore
└── README.md
```

## Linux Administration

The lab uses an Ubuntu Server virtual machine for practicing common Linux administration tasks.

Examples include:

* inspecting system information
* monitoring CPU, memory, and disk usage
* managing files and permissions
* working with processes and services
* package management
* SSH configuration and troubleshooting
* investigating network connections
* diagnosing system problems

### System Information Script

`scripts/system-info.sh` reports:

* hostname
* operating system
* kernel version
* uptime
* available memory
* disk usage
* CPU core count

## Networking

Networking fundamentals were practiced using both the Arch Linux host and Ubuntu Server virtual machines.

Topics include:

* TCP/IP
* IP addresses
* ports
* localhost
* NAT
* SSH
* client/server communication
* packet inspection with `tcpdump`

The exercises focus on understanding the path of network traffic and using tools such as `ip`, `ss`, `curl`, and `tcpdump` to troubleshoot connectivity problems.

## Bash

Bash is used for system administration and automation tasks.

The repository includes shell scripts for:

* system information
* health checks
* command-line automation
* automated checks used by CI

Shell scripts are validated with ShellCheck in GitHub Actions.

## Python System Health CLI

`python/system-health/` contains a Python command-line application that reports basic system health information.

The application collects:

* hostname
* username
* CPU core count
* memory usage
* available memory
* disk usage
* available disk space

It supports human-readable and JSON output:

```bash
python system.py
python system.py --json
```

The application also includes:

* logging
* resource usage threshold checks
* automated tests with pytest
* Docker containerization
* non-root container execution

### Testing

Python tests are located in:

```text
tests/test_system_health.py
```

Tests are executed locally with:

```bash
pytest
```

and automatically in GitHub Actions.

## Docker

The repository contains several Docker exercises progressing from basic containers to multi-container applications.

### Dockerfile Demo

Practice with:

* Dockerfiles
* image building
* container execution
* port mapping
* container lifecycle

### Website

A simple containerized website used to practice HTTP access and container networking.

### Compose Demo

A multi-container application used to practice:

* Docker Compose
* service configuration
* container networking
* service communication

### Python System Health Container

The Python system-health application is packaged as a Docker image.

The image:

* uses `python:3.12-slim`
* installs application dependencies
* runs as a non-root `appuser`
* executes the Python application as the container's main process

Example:

```bash
docker build -t system-health:dev python/system-health
docker run --rm system-health:dev
```

### Container Health Checks

The long-running HTTP application uses a Docker `HEALTHCHECK` to distinguish between a running container and a healthy application.

The Python system-health CLI does not use a Docker health check because it is a short-lived command-line application that performs its check and exits.

## Git and GitHub

Git is used throughout the project to track changes and maintain the repository.

Typical workflow:

```bash
git status
git diff
git add
git commit
git push
```

The repository is hosted on GitHub and serves as a portfolio of practical DevOps work.

## CI/CD

GitHub Actions is used to automatically validate the project when changes are pushed or pull requests are created.

The CI pipeline currently performs:

1. ShellCheck validation
2. Bash tests
3. Python dependency installation
4. Python tests with pytest
5. build artifact creation
6. Docker image build
7. Docker container execution
8. application verification
9. deployment to an Ubuntu Server self-hosted runner
10. deployment verification

### Pipeline Overview

```text
Git push / Pull Request
          │
          ▼
    GitHub Actions
          │
          ├── ShellCheck
          │
          ├── Bash tests
          │
          ├── Python tests
          │
          ├── Build artifact
          │
          ├── Docker build
          │
          ├── Docker run
          │
          └── Deployment
                 │
                 ▼
          Ubuntu Server VM
                 │
                 ▼
       Deployment verification
```

The Docker CI job also verifies the containerized HTTP application using its health check and HTTP requests.

The Python system-health Docker image is independently built and executed in CI.

## Deployment

The CI pipeline creates a build artifact containing the shell scripts and deploys it to an Ubuntu Server virtual machine.

Deployment includes:

* downloading the CI artifact
* extracting the files
* setting executable permissions
* verifying that the expected scripts exist and are executable

The deployment environment is an Ubuntu Server VM running under QEMU/KVM.

## Terraform

The `terraform/` directory contains infrastructure-as-code projects using Terraform with the Docker provider.

### First Project

`terraform/first-project/` demonstrates the basic Terraform workflow:

```text
Terraform
   │
   ├── Provider
   ├── Image
   ├── Container
   ├── Variable
   └── Output
```

The project creates and manages an Nginx Docker container.

It demonstrates:

* providers
* resources
* variables
* outputs
* resource dependencies
* Terraform state
* `terraform init`
* `terraform validate`
* `terraform plan`
* `terraform apply`
* `terraform destroy`

### Web Infrastructure

`terraform/web-infrastructure/` extends the previous project into a small multi-container infrastructure.

It creates:

* a custom Docker network
* an Nginx container
* a Redis container
* configurable container names and ports
* Terraform outputs

The Nginx and Redis containers communicate through the custom Docker network using Docker's internal DNS.

The infrastructure was verified using container-level connectivity tests and Redis `PONG` responses.

## Ansible

The `ansible/` directory contains an Ansible project for automating Ubuntu Server configuration.

The playbook:

1. installs Nginx
2. creates an application directory
3. creates a Python HTTP application
4. creates a systemd service
5. reloads systemd when the service definition changes
6. starts and enables the Python service
7. starts and enables Nginx

The resulting request path is:

```text
Client
  │
  ▼
Ubuntu :80
  │
  ▼
Nginx
  │
  ▼
127.0.0.1:8000
  │
  ▼
Python HTTP server
```

### Ansible Concepts Practiced

* inventory configuration
* SSH connectivity
* privilege escalation
* Ansible modules
* `apt`
* `file`
* `copy`
* `systemd_service`
* handlers
* variables
* service management
* idempotency

The playbook was executed repeatedly to verify idempotent behavior. Once the desired state was reached, subsequent runs reported `changed=0`.

### Troubleshooting

During development, Nginx returned a `502 Bad Gateway`.

The problem was investigated by:

1. checking the Nginx service
2. inspecting the Nginx configuration
3. checking listening ports
4. testing the upstream application directly
5. inspecting the Nginx error log
6. identifying that port `8000` had no listener
7. starting the Python backend
8. verifying the complete request path

This exercise connected Linux administration, networking, Nginx, systemd, Python, and Ansible automation.

More details are available in [`ansible/README.md`](ansible/README.md).

## Virtualization

The lab environment uses:

* QEMU/KVM
* libvirt
* virt-manager
* Ubuntu Server virtual machines
* Arch Linux host

Virtualization provides an isolated environment for Linux administration, networking, CI/CD, deployment, and automation practice.

## Troubleshooting

The `troubleshooting/` directory contains notes from problems encountered during the lab.

Examples include:

* networking issues
* Docker runtime problems
* file permission problems
* Python runtime issues
* CI/CD troubleshooting
* Nginx and backend connectivity problems
* Ansible privilege escalation issues

The goal is to document not only successful configurations, but also how problems were investigated and resolved.

## Current Progress

Completed or actively practiced:

* Linux administration
* networking fundamentals
* Bash
* Python
* Git/GitHub
* Docker
* GitHub Actions and CI/CD
* virtualization
* Terraform fundamentals
* Ansible fundamentals

### Next Focus

The next stages of the learning path are:

* AWS and cloud fundamentals
* Kubernetes
* monitoring and logging
* DevOps security
* more realistic integrated DevOps projects
* GitHub portfolio refinement
* CV and job preparation
* technical interview preparation

## Goal

The long-term goal of this lab is to develop practical skills required for junior DevOps, Cloud, Platform, and related infrastructure roles while building a portfolio of reproducible hands-on projects.

The projects are developed progressively, with an emphasis on understanding, troubleshooting, automation, and explaining how the technologies are used in real-world DevOps environments.
