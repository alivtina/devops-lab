variable "nginx_container_name" {
  description = "Name of the Docker container"
  type        = string
}

variable "nginx_port" {
  description = "Port exposed on the host"
  type        = number
}

variable "redis_container_name" {
  description = "Name of the Redis container"
  type        = string
}
