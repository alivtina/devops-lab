# Terraform Docker Infrastructure — First Project

A beginner Terraform project created to practice managing Docker infrastructure as code.

The project uses the Terraform Docker provider to create an Nginx container and demonstrates the basic Terraform workflow from configuration and planning to deployment and destruction.

## Overview

The project creates:

* an Nginx Docker image
* a Docker container managed by Terraform
* a port mapping from the host to the container

The application is available locally on port `8080`.

## Architecture

```text id="3m6v4x"
Terraform
   │
   ▼
Docker provider
   │
   ├── nginx:alpine image
   │
   └── terraform-nginx container
          │
          └── localhost:8080 → container:80
```

## What I Practiced

This project demonstrates the fundamentals of Terraform and Infrastructure as Code:

* Terraform providers
* Docker resources
* variables
* outputs
* resource dependencies
* Terraform state
* provider configuration
* Docker port mapping
* Terraform CLI workflow

The main Terraform workflow is:

```text id="n9af42"
Configuration
     ↓
terraform init
     ↓
terraform validate
     ↓
terraform plan
     ↓
terraform apply
     ↓
Infrastructure
     ↓
terraform destroy
```

## Files

```text id="3eb2y5"
first-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .terraform.lock.hcl
```

The local `terraform.tfvars` file contains environment-specific values and is excluded from Git.

Terraform-generated files such as `.terraform/` and Terraform state files are also excluded from Git.

## Requirements

* Terraform
* Docker
* Linux

Verify the required tools:

```bash
terraform version
docker version
```

Docker must be running before applying the Terraform configuration.

## Usage

### Initialize Terraform

Download the required provider and initialize the working directory:

```bash
terraform init
```

### Validate the configuration

Check the Terraform configuration for syntax and configuration errors:

```bash
terraform validate
```

### Review the planned changes

Preview the infrastructure Terraform intends to create:

```bash
terraform plan
```

### Create the infrastructure

Apply the configuration:

```bash
terraform apply
```

Terraform will ask for confirmation before creating the resources.

After deployment, the Nginx service is available at:

```text
http://localhost:8080
```

Test it with:

```bash
curl http://localhost:8080
```

### Inspect outputs

Display values exported by the Terraform configuration:

```bash
terraform output
```

### Inspect the Docker container

The created container can also be checked directly with:

```bash
docker ps
```

## Terraform State

Terraform uses a state file to keep track of the infrastructure it manages.

The state allows Terraform to compare the desired configuration with the current infrastructure and determine what changes are required.

For this local learning project, the state is stored locally and excluded from Git.

## Cleanup

Remove the infrastructure created by Terraform:

```bash
terraform destroy
```

This removes the Docker resources managed by the Terraform configuration.

## Learning Outcome

After completing this project, I can independently:

* initialize a Terraform project
* configure and use a provider
* define infrastructure as code
* use Terraform variables
* expose values through Terraform outputs
* understand basic resource dependencies
* inspect a Terraform plan
* create infrastructure with `terraform apply`
* inspect Terraform-managed resources
* understand the purpose of Terraform state
* destroy infrastructure with `terraform destroy`

## Next Step

This project provides the foundation for a more realistic Terraform project in this repository.

The [`web-infrastructure`](../web-infrastructure/) project builds on these concepts by introducing a larger infrastructure configuration and a more reusable Terraform structure.

The progression is:

```text id="w7m4i3"
First Terraform project
        ↓
Providers + resources + variables + outputs
        ↓
More realistic infrastructure
        ↓
Reusable Infrastructure as Code
```
