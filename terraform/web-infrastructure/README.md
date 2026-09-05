# Terraform Web Infrastructure

## Overview

A hands-on Terraform project that provisions a small multi-container web infrastructure using Docker.

Terraform manages a custom Docker network, Nginx and Redis images, and two containers connected to the same network.

## Architecture

```text
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
             172.20.0.2    172.20.0.3
                  │            │
            :8087 → :80       :6379
                  │
                  ▼
             Host machine
```

The containers communicate through the Docker internal network.

Docker's internal DNS allows services to be reached by container name, for example:

```text
web-redis
```

rather than relying on a fixed IP address.

## What I Practiced

* Terraform providers
* Terraform resources
* Terraform variables
* Terraform outputs
* Terraform state
* Resource dependencies
* Docker images
* Docker containers
* Docker bridge networks
* Port mapping
* Container-to-container networking
* Docker internal DNS
* Infrastructure verification
* Git and GitHub workflow

## Infrastructure

The project creates:

* A custom Docker bridge network: `web-network`
* Nginx container: `web-nginx`
* Redis container: `web-redis`
* Nginx exposed on host port `8087`
* Redis available internally on port `6379`

Redis is not exposed directly to the host because it only needs to be accessible through the internal Docker network.

## Files

```text
web-infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .terraform.lock.hcl
```

Terraform-generated files such as `.terraform/` and Terraform state files are not committed to Git.

The real `terraform.tfvars` file is also excluded from Git. Use `terraform.tfvars.example` as a template.

## Requirements

* Linux
* Docker
* Terraform

## Usage

Create your local Terraform variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the planned infrastructure:

```bash
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

Display the Terraform outputs:

```bash
terraform output
```

The Nginx service will be available at:

```text
http://localhost:8087
```

## Verification

Check running containers:

```bash
docker ps
```

Inspect the Docker network:

```bash
docker network inspect web-network
```

Test Nginx:

```bash
curl http://localhost:8087
```

Test Docker DNS and Redis connectivity:

```bash
docker run --rm --network web-network redis:alpine redis-cli -h web-redis ping
```

Expected result:

```text
PONG
```

This verifies that a container connected to the same Docker network can resolve `web-redis` through Docker DNS and communicate with Redis on port `6379`.

## Terraform Workflow

```text
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

## Cleanup

To remove the infrastructure created by Terraform:

```bash
terraform destroy
```

## Purpose

This project was built as a practical Terraform exercise to move from basic Terraform concepts toward realistic infrastructure-as-code practices.

It demonstrates how Terraform can be used to define, provision, and verify multiple interconnected services.
