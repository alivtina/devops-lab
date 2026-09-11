# DevOps Lab

A hands-on DevOps learning laboratory built on an Arch Linux host and an Ubuntu Server virtual machine.

The project focuses on practical system administration, networking, automation, containers, CI/CD, cloud fundamentals, infrastructure as code, and Kubernetes.

The goal is to build and document skills that are relevant to junior DevOps, Cloud, and Platform Engineering roles.

---

## Environment

* **Host:** Arch Linux
* **Virtualization:** QEMU/KVM, libvirt, virt-manager
* **Server:** Ubuntu Server VM
* **Container runtime:** Docker
* **Orchestration:** Kubernetes with kind
* **Package management:** pacman
* **Shell:** Bash / Zsh

---

## Repository Structure

```text
devops-lab/
├── .github/
│   └── workflows/
│       └── ci.yml
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini.example
│   ├── playbook.yml
│   └── README.md
├── docker/
│   ├── app-demo/
│   ├── compose-demo/
│   ├── dockerfile-demo/
│   ├── website/
│   └── README.md
├── helm/
│   └── webapp/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
├── kubernetes/
│   ├── README.md
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── network-policy.yaml
├── python/
│   └── system-health/
│       ├── Dockerfile
│       ├── README.md
│       ├── requirements.txt
│       └── system.py
├── scripts/
├── terraform/
│   ├── first-project/
│   └── web-infrastructure/
├── troubleshooting/
├── tests/
│   └── test_system_health.py
├── .dockerignore
├── .gitignore
└── README.md
```

---

## Skills Practiced

### Linux Administration

* Users and groups
* File ownership and permissions
* Shared directories and setgid
* SSH
* Processes and services
* Filesystems and disk usage
* System resources
* CLI troubleshooting
* Package management

### Networking

* TCP/IP fundamentals
* IP addresses and ports
* localhost
* NAT
* Routing
* SSH
* HTTP
* `curl`
* `ss`
* `ip`
* `tcpdump`
* Network troubleshooting

### Git & GitHub

* Repository management
* Branches
* Commits
* Remote repositories
* Merge and rebase workflows
* Interactive rebase
* Stashing
* GitHub Actions

### Bash & Python

* Bash scripting
* ShellCheck
* Python fundamentals
* System information and health checks
* Automated testing with pytest

### Docker

* Images and containers
* Dockerfiles
* `.dockerignore`
* Port mapping
* Environment variables
* Docker Compose
* Container troubleshooting
* Running applications as non-root users

### CI/CD

GitHub Actions pipelines are used to:

* Run ShellCheck
* Run Python tests
* Build artifacts
* Build and test Docker images
* Deploy artifacts to a self-hosted Linux runner

### Virtualization

* QEMU/KVM
* libvirt
* virt-manager
* Linux virtual machines
* Virtual networking

### Terraform

* Terraform configuration
* Variables and outputs
* Docker provider
* Container infrastructure
* Custom Docker networks
* Service discovery through container DNS
* Terraform state management
* Infrastructure verification

### Ansible

* Inventories
* Variables
* Playbooks
* Modules
* Handlers
* Privilege escalation
* Idempotency
* Automated server configuration
* Nginx deployment
* systemd service management

### AWS Fundamentals

Studied and practiced the architecture and purpose of:

* EC2
* VPC
* Subnets
* Internet Gateway
* NAT Gateway
* Security Groups
* IAM
* S3
* EBS
* RDS
* Application Load Balancer
* Auto Scaling
* Availability Zones
* CloudWatch

AWS hands-on deployment is planned for a later stage.

### Kubernetes

Hands-on practice with:

* Pods
* Deployments
* ReplicaSets
* Services
* ConfigMaps
* Secrets
* Readiness and liveness probes
* Resource requests and limits
* Rolling updates
* Rollbacks
* PersistentVolumes and PersistentVolumeClaims
* Ingress
* Namespaces
* ServiceAccounts
* RBAC
* NetworkPolicies
* Kubernetes troubleshooting

The Kubernetes lab runs locally using **kind**.

### Helm

Hands-on practice with:

* Helm charts
* `Chart.yaml`
* `values.yaml`
* Helm templates
* `helm install`
* `helm upgrade`
* `helm history`
* `helm status`
* `helm rollback`
* `helm lint`
* `helm template`
* Release revisions
* Value overrides
* `--reuse-values`

The `helm/webapp` chart deploys a configurable Nginx application to Kubernetes.

---

## Troubleshooting

The repository also contains practical troubleshooting scenarios.

Examples include:

* Linux permission problems
* Docker permission problems
* Dockerfile issues
* GitHub Actions failures
* Nginx 502 errors
* Kubernetes `ImagePullBackOff`
* Kubernetes `CrashLoopBackOff`
* Broken Service selectors
* Failed readiness and liveness probes
* Resource configuration
* Kubernetes rolling update failures
* Kubernetes rollback
* NetworkPolicy connectivity problems

The purpose is not only to configure systems, but to understand how to diagnose failures.

---

## Current Architecture

The laboratory connects multiple DevOps technologies into a single learning environment:

```text
                    Arch Linux Host
                           │
                    QEMU / KVM / libvirt
                           │
                    Ubuntu Server VM
                           │
             ┌─────────────┴─────────────┐
             │                           │
          Docker                    Kubernetes
             │                           │
       Containers                 kind cluster
             │                           │
             └──────────────┬────────────┘
                            │
                       Automation
                     ┌──────┴──────┐
                     │             │
                  Ansible       Terraform
                     │
                     └──────┬──────┘
                            │
                       GitHub Actions
                            │
                         CI / CD
```

---

## Learning Approach

The laboratory follows:

**LEARN → PRACTICE → BUILD → EXPLAIN → REVIEW**

The focus is on being able to explain and troubleshoot each technology rather than simply completing tutorials.

---

## Goal

The long-term goal of this project is to develop practical skills for:

* Junior DevOps Engineer
* Cloud Engineer
* Platform Engineer
* Site Reliability Engineer

and eventually progress toward intermediate/medior DevOps responsibilities.
