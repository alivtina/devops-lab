terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Connect Terraform to Docker
provider "docker" {}

# Create a Docker network.
# Both containers will use this network to communicate.
resource "docker_network" "web" {
  name = "web-network"
}

# Download/manage the Nginx Docker image
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

# Download/manage the Redis Docker image
resource "docker_image" "redis" {
  name = "redis:alpine"
}

# Create the Nginx container
resource "docker_container" "nginx" {
  # Container name comes from variables.tf / terraform.tfvars
  name = var.nginx_container_name

  # Use the Nginx image
  image = docker_image.nginx.image_id

  # Map host port →  container port
  # Example: localhost:8087 →  container:80
  ports {
    internal = 80
    external = var.nginx_port
  }

  # Connect Nginx to the web network
  networks_advanced {
    name = docker_network.web.name
  }
}

# Create the Redis container
resource "docker_container" "redis" {
  # Container name comes from variables.tf / terraform.tfvars
  name = var.redis_container_name

  # Use the Redis image
  image = docker_image.redis.image_id

  # Connect Redis to the same network as Nginx
  networks_advanced {
    name = docker_network.web.name
  }
}
