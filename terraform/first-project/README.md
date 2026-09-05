# Terraform Docker Infrastructure —  First Project

## Overview

A beginner Terraform project created to practice managing Docker infrastructure as code.

The project creates an Nginx Docker image and container using the Terraform Docker provider.

## Architecture

```text
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

* Terraform providers
* Docker resources
* Terraform variables
* Terraform outputs
* Resource dependencies
* Terraform state
* `terraform init`
* `terraform validate`
* `terraform plan`
* `terraform apply`
* `terraform destroy`
* Docker port mapping

## Files

```text
first-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── .terraform.lock.hcl
```

Terraform-generated files such as `.terraform/` and Terraform state files are not committed to Git.

## Requirements

* Terraform
* Docker
* Linux

## Usage

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

After deployment, the Nginx service is available on:

```text
http://localhost:8080
```

The container name can also be displayed with:

```bash
terraform output
```

## Terraform Concepts

This project demonstrates the basic Terraform workflow:

```text
Configuration
     ↓
terraform init
     ↓
terraform plan
     ↓
terraform apply
     ↓
Infrastructure
```

Terraform keeps track of the resources it manages using its state.

## Cleanup

To remove the infrastructure created by Terraform:

```bash
terraform destroy
```

## Purpose

This project was created as a learning exercise before building a more realistic multi-service Terraform infrastructure project.
