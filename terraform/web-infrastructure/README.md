# Terraform Web Infrastructure

A hands-on Terraform project that provisions a small multi-container web infrastructure using Docker.

The project builds on the basic Terraform concepts demonstrated in the [First Terraform Project](../first-project/) and introduces multiple interconnected services, a custom Docker network, container-to-container communication, and infrastructure verification.

## Goal

Use Terraform to define and provision a small interconnected application environment as Infrastructure as Code.

The project demonstrates how multiple Docker resources can be described declaratively and managed through the Terraform lifecycle.

## Architecture

```text id="6b6r1f"
                    Terraform
                        │
                        ▼
                 Docker provider
                        │
                        ▼
                 web-network
                  172.20.0.0/16
                  │          │
                  ▼          ▼
             web-nginx    web-redis
                  │            │
            host :8087     internal :6379
                  │
                  ▼
             Host machine
```

The containers communicate through the private Docker network.

Docker's internal DNS allows services to be reached by container name:

```text id="u7z7zy"
web-redis
```

rather than depending on a fixed container IP address.

The Nginx service is exposed to the host for testing, while Redis remains accessible only inside the Docker network.

## Infrastructure

Terraform creates:

* a custom Docker bridge network: `web-network`
* an Nginx container: `web-nginx`
* a Redis container: `web-redis`
* host port `8087` mapped to Nginx port `80`
* Redis available internally on port `6379`

Redis is intentionally not published to the host because it only needs to be accessible by other containers on the internal network.

## What I Practiced

This project demonstrates:

* Terraform providers
* Terraform resources
* variables
* outputs
* Terraform state
* resource dependencies
* Docker images
* Docker containers
* Docker bridge networks
* port mapping
* container-to-container networking
* Docker internal DNS
* infrastructure verification
* Git and GitHub workflow

## Prerequisites

* Linux
* Docker
* Terraform

Verify the required tools:

```bash id="trb9bc"
terraform version
docker version
```

Docker must be running before applying the Terraform configuration.

## Files

```text id="w9ddhi"
web-infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .terraform.lock.hcl
```

Terraform-generated files such as `.terraform/` and Terraform state files are excluded from Git.

The local `terraform.tfvars` file is also excluded from Git because it contains environment-specific values.

Use `terraform.tfvars.example` as the starting point for local configuration.

## Usage

### Create local variables

Copy the example variables file:

```bash id="1p0s2f"
cp terraform.tfvars.example terraform.tfvars
```

Review the values if necessary.

### Initialize Terraform

```bash id="0y9a6a"
terraform init
```

### Validate the configuration

```bash id="y9dq7d"
terraform validate
```

### Review the planned infrastructure

```bash id="rj9e8c"
terraform plan
```

### Create the infrastructure

```bash id="f0r1tx"
terraform apply
```

Terraform will ask for confirmation before creating the resources.

### Inspect Terraform outputs

```bash id="vqmyf6"
terraform output
```

## Expected Result

After a successful `terraform apply`, the environment contains:

```text id="aqnwh3"
web-network
   │
   ├── web-nginx
   │      └── host :8087 → container :80
   │
   └── web-redis
          └── internal :6379
```

The Nginx service is available at:

```text
http://localhost:8087
```

## Verification

### Check running containers

```bash id="1uq2vy"
docker ps
```

### Inspect the Docker network

```bash id="mxp39f"
docker network inspect web-network
```

This allows the connected containers and their network configuration to be inspected.

### Test Nginx

```bash id="zlf8eo"
curl http://localhost:8087
```

### Test Docker DNS and Redis connectivity

Run a temporary Redis client on the same Docker network:

```bash id="6rj4m7"
docker run --rm \
  --network web-network \
  redis:alpine \
  redis-cli -h web-redis ping
```

Expected result:

```text id="wxy8z3"
PONG
```

This verifies that:

1. the temporary container can join `web-network`
2. Docker DNS resolves `web-redis`
3. Redis is reachable on the internal network
4. Redis does not need to be exposed on a host port

## Terraform Workflow

```text id="t6gq4y"
Terraform configuration
          ↓
    terraform init
          ↓
   terraform validate
          ↓
     terraform plan
          ↓
    terraform apply
          ↓
 Docker infrastructure
          ↓
       verify
```

The same infrastructure can then be removed with:

```text id="r4y8ll"
terraform destroy
```

This demonstrates the Infrastructure as Code lifecycle:

**define → plan → apply → verify → destroy**

## Cleanup

Remove all infrastructure created by Terraform:

```bash id="3a9ryq"
terraform destroy
```

Verify that the containers and network have been removed:

```bash id="pfh6ft"
docker ps
docker network ls
```

## Learning Outcome

After completing this project, I can independently:

* define Docker infrastructure with Terraform
* configure and use the Docker provider
* create multiple related resources
* use Terraform variables and outputs
* understand Terraform resource dependencies
* create custom Docker networks
* connect multiple containers through a private network
* use Docker's internal DNS for service discovery
* expose only the services that need host access
* verify infrastructure outside Terraform
* inspect Terraform-managed infrastructure
* destroy the environment cleanly

## Progression

This project builds on the repository's first Terraform exercise:

```text id="0x4gcf"
First Terraform project
        ↓
Provider + resources + variables + outputs
        ↓
Terraform Web Infrastructure
        ↓
Multiple resources + networking + service discovery
        ↓
More realistic Infrastructure as Code
```

The project provides a foundation for later Terraform work with cloud infrastructure such as AWS.
