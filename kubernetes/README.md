# Kubernetes Lab

## Goal

Practice Kubernetes fundamentals by deploying and exposing a containerized Nginx application on a local Kubernetes cluster created with `kind`.

## Environment

* Arch Linux host
* Docker
* kind
* kubectl
* Kubernetes cluster with a single control-plane node

## Architecture

```text
Arch Linux host
      │
      │ HTTP :<NODE_PORT>
      ▼
Kind Kubernetes node
      │
      ▼
NodePort Service
nginx-deployment
      │
      │ selector: app=nginx-deployment
      ▼
┌─────────────────────────────┐
│ Deployment: nginx-deployment│
│                             │
│  ┌─────────┐  ┌─────────┐  │
│  │  Pod    │  │  Pod    │  │
│  │  Nginx  │  │  Nginx  │  │
│  └─────────┘  └─────────┘  │
└─────────────────────────────┘
```

## Deployment

The application is managed by a Kubernetes Deployment with:

* 2 replicas
* Nginx container
* `nginx:1.29-alpine` image
* Container port `80`

The Deployment maintains the desired number of Pods and replaces Pods when the Pod template changes.

## Service

A `NodePort` Service exposes the Nginx application.

* Service port: `80`
* Target port: `80`
* NodePort: dynamically assigned by Kubernetes

The Service uses the selector:

```text
app=nginx-deployment
```

This ensures that traffic is sent only to the Pods belonging to this Deployment.

## ConfigMap

A ConfigMap provides non-sensitive configuration to Kubernetes Pods.

This lab uses `nginx-config` with:

```text
APP_ENV=development
APP_MESSAGE=Hello from Kubernetes
```

The Deployment injects the ConfigMap values into the container as environment variables:

```yaml
envFrom:
  - configMapRef:
      name: nginx-config
```

The configuration was verified inside a running Pod:

```bash
kubectl exec <POD_NAME> -- env | grep APP_
```

Expected output:

```text
APP_ENV=development
APP_MESSAGE=Hello from Kubernetes
```

ConfigMaps allow application configuration to be separated from the container image.

## Secret

A Kubernetes Secret is used for sensitive configuration such as passwords, API keys, and tokens.

This lab uses a Secret named `app-secret` containing:

```text
DB_PASSWORD=super-secret-password
```

The Secret is injected into the Deployment as an environment variable:

```yaml
envFrom:
  - configMapRef:
      name: nginx-config
  - secretRef:
      name: app-secret
```

The Secret was verified inside a running Pod:

```bash
kubectl exec <POD_NAME> -- env | grep DB_PASSWORD
```

Expected output:

```text
DB_PASSWORD=super-secret-password
```

The Secret manifest contains a plaintext test password and is therefore intentionally excluded from Git using `.gitignore`:

```text
kubernetes/secret.yaml
```

The Secret exists only in the local Kubernetes cluster for this lab.

In a production environment, sensitive credentials should be managed securely, for example with an external secret-management system or another appropriate secret delivery mechanism.

## What I Practiced

* Created a local Kubernetes cluster with `kind`
* Used `kubectl` to manage Kubernetes resources
* Created a Deployment using declarative YAML
* Created a NodePort Service using declarative YAML
* Used labels and selectors to connect Services to Pods
* Inspected Pod IP addresses and EndpointSlices
* Tested Service connectivity from inside the cluster
* Tested NodePort connectivity from the host
* Scaled a Deployment from 2 to 3 replicas
* Practiced Kubernetes desired-state reconciliation
* Performed a rolling update from `nginx:alpine` to `nginx:1.29-alpine`
* Injected non-sensitive configuration using a ConfigMap
* Injected sensitive configuration using a Secret
* Verified ConfigMap and Secret environment variables inside a running container
* Practiced keeping sensitive configuration out of Git

## Verification

Check the Deployment:

```bash
kubectl get deployments
```

Check Pods:

```bash
kubectl get pods -o wide
```

Check Services:

```bash
kubectl get services
```

Check Service endpoints:

```bash
kubectl get endpointslices
```

Check the ConfigMap:

```bash
kubectl describe configmap nginx-config
```

Check the Secret:

```bash
kubectl get secret app-secret
```

Test the Service from inside the cluster:

```bash
kubectl run curl --image=curlimages/curl:latest --rm -it -- curl http://nginx-deployment
```

Test the NodePort from the host:

```bash
curl http://<KIND_NODE_IP>:<NODE_PORT>
```

Check the current container image:

```bash
kubectl get deployment nginx-deployment \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Check ConfigMap environment variables:

```bash
kubectl exec <POD_NAME> -- env | grep APP_
```

Check Secret environment variables:

```bash
kubectl exec <POD_NAME> -- env | grep DB_PASSWORD
```
