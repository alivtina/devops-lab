# Kubernetes Lab

## Goal

Practice Kubernetes fundamentals by deploying, exposing, configuring, securing, and troubleshooting a containerized Nginx web application on a local Kubernetes cluster created with `kind`.

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
      │ kubectl / curl
      ▼
┌─────────────────────────────────────────┐
│              Kind cluster               │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Ingress: webapp.local             │  │
│  └─────────────────┬─────────────────┘  │
│                    │                    │
│  ┌─────────────────▼─────────────────┐  │
│  │ Service: webapp                   │  │
│  │ ClusterIP :80                     │  │
│  └─────────────────┬─────────────────┘  │
│                    │ selector           │
│                    │ app=webapp         │
│              ┌─────┴─────┐              │
│              ▼           ▼              │
│          ┌────────┐  ┌────────┐         │
│          │ Pod    │  │ Pod    │         │
│          │ Nginx  │  │ Nginx  │         │
│          └────────┘  └────────┘         │
│              │           │              │
│              ├─ ConfigMap                │
│              ├─ Secret                   │
│              ├─ Probes                   │
│              └─ Resources                │
│                                         │
│  NetworkPolicy controls Pod traffic     │
└─────────────────────────────────────────┘
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

The Service provides stable networking to Pods matching its selector.

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

## Persistent Storage

A PersistentVolumeClaim (PVC) was used to provide persistent storage to a Pod.

The PVC requested:

```yaml
accessModes:
  - ReadWriteOnce
resources:
  requests:
    storage: 1Gi
```

The cluster dynamically provisioned a PersistentVolume using the default `local-path` StorageClass.

The PVC initially remained `Pending` because the StorageClass uses `WaitForFirstConsumer`. After a Pod consumed the PVC, it became `Bound`.

A test file was written to the mounted volume:

```bash
kubectl exec storage-demo -- \
  sh -c 'echo "Hello from persistent storage" > /data/hello.txt'
```

The Pod was then deleted and recreated. The file remained available after the new Pod started, demonstrating persistence across Pod replacement.

Key concepts practiced:

* PersistentVolumeClaim
* PersistentVolume
* StorageClass
* `ReadWriteOnce`
* Dynamic provisioning
* `WaitForFirstConsumer`
* Persistent data across Pod replacement

## Ingress

An NGINX Ingress Controller was installed in the local `kind` cluster.

An Ingress resource routes HTTP traffic for:

```text
webapp.local
```

to the `webapp` Service.

The routing configuration uses:

```yaml
rules:
  - host: webapp.local
    http:
      paths:
        - path: /
          pathType: Prefix
```

The request path was tested end-to-end:

```text
Arch host
    ↓
NGINX Ingress Controller
    ↓
Ingress rule: webapp.local /
    ↓
webapp Service :80
    ↓
webapp Pods
    ↓
Nginx
```

The hostname was mapped locally using `/etc/hosts`.

Verification:

```bash
curl http://webapp.local:30827
```

This demonstrated the difference between:

* **Service** — provides stable networking to Pods
* **Ingress** — defines HTTP/HTTPS routing rules
* **Ingress Controller** — implements the actual routing

## Namespaces and RBAC

A separate `development` Namespace was created to practice resource isolation and access control.

A ServiceAccount named `webapp-reader` was created with a Role that allows:

```text
get
list
watch
```

on Pods.

A RoleBinding connects the ServiceAccount to the Role.

The permission model is:

```text
ServiceAccount
      ↓
RoleBinding
      ↓
Role
      ↓
get / list / watch Pods
```

Permissions were verified with:

```bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:development:webapp-reader \
  -n development
```

Result:

```text
yes
```

Unauthorized operations were also tested:

```bash
kubectl auth can-i delete pods \
  --as=system:serviceaccount:development:webapp-reader \
  -n development
```

Result:

```text
no
```

This demonstrated basic Kubernetes RBAC using:

* Namespace
* ServiceAccount
* Role
* RoleBinding
* `kubectl auth can-i`

## NetworkPolicy

A NetworkPolicy was used to control Pod-to-Pod traffic.

The `allow-client-to-server` policy selects Pods with:

```text
run=server
```

and allows ingress only from Pods with:

```text
role=client
```

on TCP port `80`.

The policy therefore allows:

```text
client ──────→ server :80
   ✅
```

while blocking unauthorized Pods:

```text
attacker ────→ server :80
   ❌
```

The allowed connection was verified with:

```bash
kubectl exec -n development client -- \
  curl -I --max-time 5 http://10.244.0.53
```

Result:

```text
HTTP/1.1 200 OK
```

An unauthorized connection was tested with:

```bash
kubectl exec -n development attacker -- \
  curl -I --max-time 5 http://10.244.0.53
```

Result:

```text
curl: (28) Connection timed out
```

This demonstrated how NetworkPolicy can restrict network communication between Pods based on labels.

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
* Used PersistentVolumeClaims and PersistentVolumes
* Practiced dynamic storage provisioning
* Tested persistence across Pod replacement
* Configured an Ingress and NGINX Ingress Controller
* Practiced Namespaces
* Created ServiceAccounts
* Configured basic RBAC with Roles and RoleBindings
* Verified RBAC permissions with `kubectl auth can-i`
* Configured NetworkPolicy
* Tested allowed and blocked Pod-to-Pod traffic
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

Check RBAC:

```bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:development:webapp-reader \
  -n development
```

Check NetworkPolicy:

```bash
kubectl get networkpolicy -n development
```

## Files

```text
kubernetes/
├── README.md
├── deployment.yaml
├── service.yaml
├── configmap.yaml
└── network-policy.yaml
```

The Secret manifest is intentionally not stored in the repository.

The PersistentVolume and Ingress resources used during the lab were created as separate exercises and can be added to the repository when they are finalized as reusable manifests.
