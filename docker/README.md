# Docker Practice

A hands-on Docker laboratory demonstrating how to build, run, configure, network, test, and troubleshoot containerized applications using Docker and Docker Compose.

The projects progress from individual Dockerfile concepts to multi-container environments and a small containerized Python application.

## What This Lab Demonstrates

* Docker images and containers
* Container lifecycle and `docker exec`
* Dockerfiles and image layers
* Build cache and build context
* `.dockerignore`
* `CMD` and `ENTRYPOINT`
* Container networking and Docker DNS
* Port publishing
* Bind mounts and named volumes
* Environment variables
* Container healthchecks
* Running containers as a non-root user
* Docker Compose

---

## Projects

### 1. Containerized Python Application

**Directory:** [`app-demo/`](app-demo/)

A small Python HTTP application packaged into a Docker image.

The application demonstrates:

* building a custom Docker image
* copying application code into an image
* publishing container ports
* environment variables
* running as a non-root user
* Docker `HEALTHCHECK`
* an HTTP health endpoint

#### Build

```bash
cd app-demo
docker build -t app-demo .
```

#### Run

```bash
docker run -d \
  --name app-demo \
  -p 8080:8000 \
  -e APP_ENV=production \
  app-demo
```

#### Test

```bash
curl http://localhost:8080/
```

Expected:

```text
Hello from Docker! Environment: production
```

Health endpoint:

```bash
curl http://localhost:8080/health
```

Expected:

```text
OK
```

Check container health:

```bash
docker ps
```

The container should eventually show:

```text
(healthy)
```

Remove the container:

```bash
docker rm -f app-demo
```

### Run with Docker Compose

The application can also be started using Docker Compose:

```bash
docker compose -f docker/app-demo/compose.yaml up -d
```

Check the service:

```bash
docker compose -f docker/app-demo/compose.yaml ps
```

Test the application:

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

Stop the application:

```bash
docker compose -f docker/app-demo/compose.yaml down
```

The Compose configuration demonstrates:

* building an image from a Dockerfile
* port publishing
* environment variable configuration
* a container restart policy
* Docker healthchecks
* managing the application lifecycle with Docker Compose

---

### 2. Docker Compose Demo

**Directory:** [`compose-demo/`](compose-demo/)

A two-service Docker Compose environment consisting of:

* `web` — Nginx
* `app` — Alpine Linux

Both services are connected to the same Compose network.

```text
Host
  |
  | localhost:8080
  v
web (nginx)

app (alpine)
  |
  | Docker Compose network
  | http://web
  v
web (nginx)
```

The example demonstrates:

* multiple containers managed with Compose
* service-to-service communication
* Docker DNS / service discovery
* port publishing
* named volumes and volume mounts
* environment variables
* container lifecycle with Compose

The `app` container runs `sleep infinity` so it can be used as a shell environment for testing communication with the `web` service.

The named volume is mounted at `/data` to demonstrate persistent storage, although this particular demo does not actively write application data to the volume.

#### Start

From the repository root:

```bash
docker compose -f docker/compose-demo/compose.yaml up -d
```

Check the services:

```bash
docker compose -f docker/compose-demo/compose.yaml ps
```

Test access from the host:

```bash
curl http://localhost:8080
```

Test communication between containers:

```bash
docker compose -f docker/compose-demo/compose.yaml exec app wget -qO- http://web
```

Stop the services:

```bash
docker compose -f docker/compose-demo/compose.yaml down
```

The named volume remains after `down` unless `-v` is used.

---

### 3. Dockerfile Examples

**Directory:** [`dockerfile-demo/`](dockerfile-demo/)

Small Dockerfiles used to practice individual Dockerfile instructions and image-building concepts.

Examples include:

* `FROM`
* `RUN`
* `COPY`
* `CMD`
* `ENTRYPOINT`
* image layers
* build cache
* build context

#### Example: package a Bash script into an image

`Dockerfile.copy` packages the existing `system-info.sh` script from the repository into an Ubuntu-based image.

Because the Dockerfile copies a file from `scripts/`, the repository root must be used as the build context.

Build from the repository root:

```bash
docker build \
  -f docker/dockerfile-demo/Dockerfile.copy \
  -t system-info-demo:v1 .
```

Run:

```bash
docker run --rm system-info-demo:v1
```

The container executes the system information script and displays information such as:

* hostname
* kernel
* memory
* disk usage
* IP address
* CPU count

---

### 4. Website Bind Mount

**Directory:** [`website/`](website/)

A minimal HTML page used to demonstrate Docker bind mounts.

A bind mount maps a file or directory from the host into a container.

This allows changes made on the host to become visible inside the container without rebuilding the image.

For example:

```bash
docker run --rm \
  -p 8080:80 \
  -v "$(pwd)/docker/website:/usr/share/nginx/html:ro" \
  nginx
```

The `:ro` option mounts the files as read-only inside the container.

Test the website:

```bash
curl http://localhost:8080
```

---

## Key Concepts Practiced

| Concept               | Demonstrated in               |
| --------------------- | ----------------------------- |
| Images and containers | All examples                  |
| Dockerfiles           | `dockerfile-demo`, `app-demo` |
| Build cache           | `dockerfile-demo`             |
| Build context         | `dockerfile-demo`             |
| `.dockerignore`       | `app-demo`                    |
| Port publishing       | `app-demo`, `compose-demo`    |
| Container networking  | `compose-demo`                |
| Docker DNS            | `compose-demo`                |
| Named volumes         | `compose-demo`                |
| Bind mounts           | `website`                     |
| Environment variables | `app-demo`, `compose-demo`    |
| Healthchecks          | `app-demo`                    |
| Non-root containers   | `app-demo`                    |
| Docker Compose        | `app-demo`, `compose-demo`    |

---

## Learning Outcome

After completing these exercises, I can independently:

* build Docker images from Dockerfiles
* run and manage containers
* publish container ports
* pass configuration through environment variables
* persist data with Docker volumes
* connect containers through Docker networks
* use Docker Compose to manage multiple services
* debug basic container networking problems
* add and verify container healthchecks
* run application containers as non-root users
* inspect images, containers, networks, and volumes
* test containerized applications from the host and between containers
* automate Docker image builds and application tests with GitHub Actions

The project provides the foundation for using containers in later CI/CD, Kubernetes, and deployment projects.
