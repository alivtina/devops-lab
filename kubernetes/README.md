# Kubernetes Lab

## Goal

Practice Kubernetes fundamentals by deploying, exposing, configuring, health-checking, and troubleshooting a containerized Nginx web application on a local Kubernetes cluster created with `kind`.

The lab focuses on practical Kubernetes tasks commonly used in DevOps work.

## Environment

* Arch Linux host
* Docker
* kind
* kubectl
* Local Kubernetes cluster with a single control-plane node
* Nginx `1.29-alpine`

## Architecture

```text
Arch Linux host
      │
      │ kubectl
      ▼
┌──────────────────────────────┐
│       Kind cluster           │
│                              │
│  ┌────────────────────────┐  │
│  │ Service: webapp        │  │
│  │ ClusterIP :80          │  │
│  └───────────┬────────────┘  │
│              │ selector      │
│              │ app=webapp    │
│       ┌──────┴──────┐        │
│       ▼             ▼        │
│   ┌────────┐    ┌────────┐   │
│   │ Pod    │    │ Pod    │   │
│   │ Nginx  │    │ Nginx  │   │
│   └────────┘    └────────┘   │
│       │             │        │
│       ├─ ConfigMap            │
│       ├─ Secret               │
│       ├─ Probes               │
│       └─ Resources            │
└──────────────────────────────┘
```

## Deployment

The application is managed by a Kubernetes Deployment named `webapp`.

Configuration:

* 2 replicas
* Nginx `1.29-alpine`
* Container port `80`
* ConfigMap environment variables
* Secret environment variable
* Readiness probe
* Liveness probe
* CPU and memory requests/limits

The Deployment maintains the desired number of Pods and performs rolling updates when the Pod template changes.

Check the Deployment:

```bash
kubectl get deployment webapp
kubectl describe deployment webapp
```

## Service

The application is exposed internally through a `ClusterIP` Service named `webapp`.

Configuration:

* Service port: `80`
* Target port: `80`
* Selector: `app=webapp`

The Service automatically routes traffic to healthy Pods matching its selector.

Check the Service:

```bash
kubectl get service webapp
kubectl describe service webapp
```

Check the endpoints:

```bash
kubectl get endpointslices
```

The EndpointSlice contains the IP addresses of the Pods selected by the Service.

Test connectivity from inside the cluster:

```bash
kubectl run curl \
  --image=curlimages/curl:latest \
  --rm -it -- \
  curl http://webapp
```

## ConfigMap

A ConfigMap provides non-sensitive application configuration.

This lab uses `webapp-config`:

```text
APP_ENV=development
APP_MESSAGE=Hello from Kubernetes
```

The Deployment injects the values as environment variables:

```yaml
envFrom:
  - configMapRef:
      name: webapp-config
```

Verify the configuration inside a running Pod:

```bash
kubectl exec deploy/webapp -- env | grep APP_
```

ConfigMaps allow application configuration to be separated from the container image.

## Secret

A Kubernetes Secret is used for sensitive configuration.

This lab uses a local Secret named `webapp-secret` containing a test database password.

The Deployment injects it as an environment variable:

```yaml
envFrom:
  - secretRef:
      name: webapp-secret
```

The Secret manifest is intentionally excluded from Git because it contains a plaintext test password.

The local Secret can be checked with:

```bash
kubectl get secret webapp-secret
```

For a real production environment, credentials should be managed using an appropriate secret-management solution rather than committed to Git.

## Health Probes

The application uses both readiness and liveness probes.

### Readiness probe

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 2
  periodSeconds: 5
```

The readiness probe determines whether a Pod is ready to receive traffic.

A failed readiness probe makes the Pod `NotReady` but does not restart the container.

### Liveness probe

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```

The liveness probe determines whether the container should be restarted.

A failed liveness probe can cause Kubernetes to restart the container.

The practical distinction is:

```text
Readiness → Should this Pod receive traffic?

Liveness  → Should this container be restarted?
```

## Resource Requests and Limits

The containers define CPU and memory resources:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "64Mi"
  limits:
    cpu: "500m"
    memory: "128Mi"
```

Requests influence scheduling and represent the resources Kubernetes expects the container to require.

Limits define the maximum resources the container can use.

The resulting Pod has `Burstable` QoS.

Check resources with:

```bash
kubectl describe pod -l app=webapp
```

## Rolling Updates

The Deployment uses Kubernetes rolling updates.

A new image version can be deployed with:

```bash
kubectl set image deployment/webapp nginx=nginx:<VERSION>
```

Kubernetes creates new Pods while gradually replacing the old Pods.

Check rollout status:

```bash
kubectl rollout status deployment/webapp
```

View rollout history:

```bash
kubectl rollout history deployment/webapp
```

## Rollback

A failed deployment was intentionally simulated by changing the image to a non-existent image:

```text
nginx:this-image-does-not-exist
```

The new Pod entered:

```text
ImagePullBackOff
```

The existing healthy Pods remained running while Kubernetes attempted the rolling update.

The failed rollout was diagnosed using:

```bash
kubectl get pods -l app=webapp
kubectl describe pod <POD_NAME>
```

The problem was identified as an invalid container image.

The previous healthy revision was restored with:

```bash
kubectl rollout undo deployment/webapp
```

The rollout was then verified:

```bash
kubectl rollout status deployment/webapp
kubectl get pods -l app=webapp
```

This demonstrated a complete deployment recovery workflow:

```text
Deploy
  ↓
New Pod fails
  ↓
Inspect status
  ↓
Inspect Pod details/events
  ↓
Identify root cause
  ↓
Rollback
  ↓
Verify healthy state
```

## Troubleshooting

The lab included several Kubernetes troubleshooting scenarios.

### ImagePullBackOff

Cause:

* Invalid or unavailable container image.

Useful commands:

```bash
kubectl get pods
kubectl describe pod <POD_NAME>
```

Container logs are generally unavailable when the container never successfully starts.

### CrashLoopBackOff

Cause:

* Application starts but repeatedly exits or crashes.

Useful commands:

```bash
kubectl get pods
kubectl logs <POD_NAME>
kubectl describe pod <POD_NAME>
```

### Service selector mismatch

A Service with an incorrect selector produced an empty EndpointSlice.

Troubleshooting:

```bash
kubectl describe service <SERVICE_NAME>
kubectl get endpointslices
kubectl get pods --show-labels
```

The issue was resolved by matching the Service selector with the Pod labels.

### Probe failure

Readiness and liveness failures were intentionally tested.

A readiness failure resulted in:

```text
0/1 Running
```

The container was still running, but Kubernetes considered the Pod not ready to receive traffic.

A liveness failure caused the container to restart.

## What I Practiced

* Created a local Kubernetes cluster with `kind`
* Used `kubectl` to manage Kubernetes resources
* Created Deployments using declarative YAML
* Created and inspected Services
* Used labels and selectors
* Inspected EndpointSlices
* Tested Service connectivity from inside the cluster
* Scaled Deployments
* Practiced Kubernetes desired-state reconciliation
* Performed rolling updates
* Performed deployment rollbacks
* Used ConfigMaps for non-sensitive configuration
* Used Secrets for sensitive configuration
* Kept Secret configuration out of Git
* Configured readiness probes
* Configured liveness probes
* Configured CPU and memory requests/limits
* Investigated `ImagePullBackOff`
* Investigated `CrashLoopBackOff`
* Investigated Service selector problems
* Investigated health probe failures
* Used `kubectl describe`, `kubectl logs`, `kubectl exec`, and rollout commands for troubleshooting

## Verification

Check the application:

```bash
kubectl get deployment webapp
kubectl get pods -l app=webapp
kubectl get service webapp
kubectl get endpointslices
```

Check configuration:

```bash
kubectl exec deploy/webapp -- env | grep APP_
kubectl exec deploy/webapp -- env | grep DB_PASSWORD
```

Check probes and resources:

```bash
kubectl describe pod -l app=webapp
```

Check rollout:

```bash
kubectl rollout status deployment/webapp
kubectl rollout history deployment/webapp
```

Test the Service:

```bash
kubectl run curl \
  --image=curlimages/curl:latest \
  --rm -it -- \
  curl http://webapp
```

## Files

```text
kubernetes/
├── README.md
├── deployment.yaml
├── service.yaml
└── configmap.yaml
```

The Secret manifest is intentionally not stored in the repository.
