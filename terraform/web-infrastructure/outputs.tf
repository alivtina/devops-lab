output "nginx_url" {
  description = "URL of the Nginx service"
  value       = "http://localhost:${var.nginx_port}"
}

output "nginx_container_name" {
  description = "Name of the Nginx container"
  value       = docker_container.nginx.name
}

output "redis_container_name" {
  description = "Name of the Redis container"
  value       = docker_container.redis.name
}
