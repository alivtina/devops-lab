# DevOps Lab

A hands-on DevOps laboratory focused on building practical skills in Linux administration, networking, automation, containers, CI/CD, infrastructure as code, Kubernetes, cloud fundamentals, and monitoring.

The repository contains small experiments, reusable configurations, troubleshooting exercises, and progressively more realistic infrastructure projects.

The goal is to move from individual Linux and container tasks toward reproducible, automated infrastructure and deployment workflows.

---

## Project Summary

**DevOps Lab is a practical infrastructure and automation portfolio demonstrating how I build, deploy, automate, monitor, and troubleshoot software environments.**

The repository brings together Linux administration, networking, Git, Bash and Python scripting, Docker, CI/CD, Ansible, Terraform, Kubernetes, Helm, and Prometheus into a single hands-on learning environment.

Rather than focusing only on theoretical exercises, the projects demonstrate practical workflows such as:

* configuring and troubleshooting Linux servers
* automating server configuration with Ansible
* building and testing Docker containers
* creating CI pipelines with GitHub Actions
* provisioning infrastructure with Terraform
* deploying applications to Kubernetes
* packaging Kubernetes applications with Helm
* monitoring Kubernetes workloads with Prometheus
* creating alerts for infrastructure problems
* investigating failures using logs, metrics, processes, networking tools, and Kubernetes diagnostics

The laboratory runs primarily on **Linux with QEMU/KVM, libvirt, Docker, and a local Kubernetes cluster**, allowing infrastructure and deployment scenarios to be tested in a controlled environment.

### What this demonstrates

This portfolio is intended to demonstrate that I can:

**build → automate → deploy → monitor → troubleshoot → improve**

a technical environment rather than only configure individual tools in isolation.

---

## Quick Start

Clone the repository:

```bash
git clone git@github.com:alivtina/devops-lab.git
cd devops-lab
```

### Docker

```bash
docker build -t app-demo ./docker/app-demo
docker run --rm -p 8080:8000 app-demo
```

Test the application:

```bash
curl http://localhost:8080/health
```

### Helm

```bash
helm lint helm/webapp
helm template webapp helm/webapp
```

### Python

```bash
pytest
```

### Shell scripts

```bash
shellcheck scripts/*.sh
```

Some projects require additional infrastructure such as Docker, Kubernetes, Helm, Terraform, Ansible, or a Linux virtual machine.

---

## Projects

| Area                                | Description                                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [Docker](docker/)                   | Container images, Dockerfiles, Compose, health checks, users, networking, volumes, and troubleshooting |
| [Kubernetes](kubernetes/)           | Deployments, Services, ConfigMaps, Secrets, probes, resources, NetworkPolicy, and troubleshooting      |
| [Helm](helm/)                       | Packaging and templating Kubernetes applications with Helm                                             |
| [Monitoring](monitoring/)           | Prometheus-based Kubernetes monitoring, PromQL, metrics, and alerting                                  |
| [Terraform](terraform/)             | Infrastructure as Code and reproducible infrastructure                                                 |
| [Ansible](ansible/)                 | Automated Linux server configuration and web server deployment                                         |
| [Python](python/)                   | Python automation and system health monitoring                                                         |
| [Scripts](scripts/)                 | Bash utilities for system information and health checks                                                |
| [Tests](tests/)                     | Automated tests for scripts and Python applications                                                    |
| [Troubleshooting](troubleshooting/) | Investigation and diagnosis of infrastructure problems                                                 |

A separate Linux Server Lab also contains hands-on Linux administration, SSH, permissions, services, networking, Bash scripting, Git, and CI exercises.

---

## What I Can Do

This repository demonstrates practical experience with:

* administering Linux systems from the command line
* working with users, groups, permissions, processes, services, and filesystems
* troubleshooting Linux systems using logs, processes, networking tools, and system resources
* working with TCP/IP networking, NAT, SSH, and basic network troubleshooting
* using Git and GitHub for version control and project collaboration
* writing Bash scripts for system administration and automation
* writing Python utilities for system monitoring and automation
* building and troubleshooting Docker images and containers
* creating Docker Compose environments
* running containers as non-root users
* implementing container health checks
* building CI workflows with GitHub Actions
* running automated tests and static analysis
* deploying applications to Linux environments
* creating Kubernetes Deployments, Services, ConfigMaps, Secrets, and NetworkPolicies
* configuring Kubernetes probes and resource requests/limits
* packaging Kubernetes applications with Helm
* writing PromQL queries and configuring Prometheus alerts
* automating Linux server configuration with Ansible
* managing infrastructure with Terraform
* working with virtualized Linux environments using QEMU/KVM and libvirt
* understanding the fundamentals of AWS cloud infrastructure
* investigating infrastructure failures instead of relying only on predefined solutions

---

## Technology Stack

### Operating Systems

* Arch Linux
* Ubuntu Server

### Virtualization

* QEMU/KVM
* libvirt
* virt-manager

### Linux & Networking

* Linux CLI
* systemd
* SSH
* TCP/IP
* NAT
* processes and services
* filesystems
* permissions
* resource monitoring
* troubleshooting

### Version Control & CI/CD

* Git
* GitHub
* GitHub Actions
* ShellCheck
* pytest
* CI pipelines
* artifacts
* self-hosted Linux runners

### Programming & Automation

* Bash
* Python
* C

### Containers

* Docker
* Dockerfiles
* Docker Compose
* container networking
* volumes
* environment variables
* health checks
* container security basics

### Kubernetes

* Kubernetes
* kind
* Deployments
* Services
* ConfigMaps
* Secrets
* probes
* resource requests and limits
* NetworkPolicy
* rolling updates
* troubleshooting

### Kubernetes Packaging

* Helm
* Helm charts
* templates
* values
* releases

### Infrastructure as Code

* Terraform
* Ansible

### Cloud

* AWS fundamentals
* cloud infrastructure concepts
* networking and compute fundamentals

### Monitoring

* Prometheus
* PromQL
* Alertmanager
* Node Exporter
* kube-state-metrics
* Kubernetes metrics
* alerting

---

## Laboratory Environment

The main laboratory runs on an Arch Linux workstation.

```text
Arch Linux host
      │
      ├── QEMU/KVM
      │      └── Ubuntu Server VM
      │
      └── Docker
             └── kind Kubernetes cluster
                    ├── Kubernetes workloads
                    └── Prometheus monitoring
```

The environment is intentionally local and reproducible so that infrastructure changes, failures, configuration changes, and troubleshooting can be tested safely.

---

## Kubernetes & Monitoring

The Kubernetes laboratory uses a local `kind` cluster.

The monitoring stack is deployed with Helm in the `monitoring` namespace and includes:

* Prometheus
* Alertmanager
* Node Exporter
* kube-state-metrics
* Pushgateway

The monitoring configuration includes practical Prometheus alerts such as:

* high CPU usage
* Kubernetes container restarts

The repository contains the Helm values used to configure the monitoring stack.

See [Monitoring](monitoring/) for configuration, PromQL examples, alerts, and troubleshooting.

---

## Infrastructure as Code

Terraform projects demonstrate the basic Infrastructure as Code workflow:

```text
Write configuration
       ↓
terraform init
       ↓
terraform plan
       ↓
terraform apply
       ↓
Inspect infrastructure
       ↓
terraform destroy
```

The projects focus on understanding:

* providers
* resources
* variables
* outputs
* state
* plans
* dependencies
* reproducible infrastructure

Ansible projects demonstrate configuration management and server automation:

```text
Control machine
      ↓
Inventory
      ↓
Playbook
      ↓
SSH
      ↓
Remote Linux server
      ↓
Configured service
```

---

## CI/CD

GitHub Actions is used to automate validation and deployment-related tasks.

Examples include:

* ShellCheck
* Python tests
* artifact handling
* Docker image builds
* Docker tests
* deployment to a self-hosted Linux runner

The purpose is to practice the core CI/CD workflow:

```text
Code
 ↓
Commit
 ↓
Push
 ↓
CI
 ├── Static analysis
 ├── Tests
 └── Build
 ↓
Deployment
```

---

## Troubleshooting

Troubleshooting is treated as an important part of the laboratory rather than an afterthought.

Exercises focus on investigating problems using evidence such as:

```bash
systemctl status
journalctl
ps
top
free
df
ss
ip
curl
docker logs
docker inspect
kubectl describe
kubectl logs
kubectl get events
```

The objective is to develop a systematic approach:

```text
Observe
   ↓
Collect evidence
   ↓
Identify the failing component
   ↓
Form a hypothesis
   ↓
Test the hypothesis
   ↓
Fix the problem
   ↓
Verify the result
   ↓
Document the solution
```

---

## Learning Approach

The projects follow a practical learning cycle:

**LEARN → PRACTICE → BUILD → EXPLAIN → REVIEW**

Instead of only following tutorials, each topic is reinforced through hands-on work and troubleshooting.

The repository therefore contains both:

* small exercises used to learn individual concepts
* larger projects combining multiple DevOps skills

The projects are intentionally developed incrementally as new technologies are learned.

---

## Current Learning Direction

The current progression is:

```text
Linux
  ↓
Networking
  ↓
Git & GitHub
  ↓
Bash
  ↓
Python
  ↓
Docker
  ↓
CI/CD
  ↓
AWS
  ↓
Terraform
  ↓
Kubernetes
  ↓
Monitoring & Logging
  ↓
Security
  ↓
Real-world DevOps projects
  ↓
Portfolio & Job Preparation
```

The focus is not simply on completing courses or tutorials.

A technology is considered learned when I can use it to solve a practical problem, troubleshoot failures, and explain the underlying concepts.

---

## Portfolio Goal

The long-term goal of this repository is to demonstrate the practical skills required for junior and eventually intermediate/medior DevOps, Cloud, Platform, or Site Reliability Engineering roles.

The portfolio is being built around realistic engineering tasks rather than isolated technology demonstrations.

The target workflow is:

```text
Linux administration
        +
Networking
        +
Programming & scripting
        +
Containers
        +
CI/CD
        +
Infrastructure as Code
        +
Cloud
        +
Kubernetes
        +
Monitoring
        +
Security
        ↓
Reliable automated infrastructure
```

---

## Repository Structure

```text
devops-lab/
├── ansible/               # Linux configuration management
├── docker/                # Docker and Compose projects
├── helm/                  # Helm charts
├── kubernetes/            # Kubernetes manifests
├── monitoring/            # Prometheus configuration
├── python/                # Python automation projects
├── scripts/               # Bash utilities
├── terraform/             # Infrastructure as Code
├── tests/                 # Automated tests
└── troubleshooting/       # Troubleshooting exercises
```

---

## Verification

Before committing changes, the main projects can be checked with tools such as:

```bash
shellcheck scripts/*.sh
pytest
helm lint helm/webapp
helm template webapp helm/webapp
terraform fmt -check
```

Additional validation commands are documented inside the individual project directories.

---

## Status

This is an actively evolving laboratory.

Some technologies are already demonstrated through hands-on projects, while others are still being expanded toward more realistic production-style scenarios.

The repository will continue to evolve as the laboratory progresses from individual technical exercises toward integrated DevOps projects.
