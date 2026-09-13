# Kubernetes Web Application Lab

Practice Kubernetes fundamentals by deploying, exposing, configuring, securing, and troubleshooting a containerized Nginx web application on a local Kubernetes cluster created with `kind`.

## Goal

This project demonstrates practical Kubernetes concepts through a small web application deployed to a local cluster.

The main repository manifests focus on:

* Deployments
* Services
* ConfigMaps
* resource requests and limits
* health probes
* rolling updates
* NetworkPolicy

Additional Kubernetes features such as persistent storage, Ingress, RBAC, and troubleshooting scenarios were also practiced using separate local manifests kept outside the repository.

## Environment

* Host: Arch Linux
* Kubernetes cluster: `kind`
* Container runtime: Docker
* Application: Nginx
* Repository: `devops-lab`

## Architecture

```text
                    ┌─────────────────────┐
                    │   kind cluster     │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  Deployment   │  │
                    │  │    webapp     │  │
                    │  └───────┬───────┘  │
                    │          │          │
                    │      ┌───▼───┐      │
                    │      │ Nginx │      │
                    │      │ Pods   │      │
                    │      └───┬───┘      │
                    │          │          │
                    │     ┌────▼─────┐    │
                    │     │ Service  │    │
                    │     │ ClusterIP│    │
                    │     └──────────┘    │
                    │                     │
                    └─────────────────────┘
```

The application is exposed internally through a Kubernetes `Service`.

Configuration is provided through a `ConfigMap`, while network access between Pods is controlled using a `NetworkPolicy`.

## Repository Structure

```text
kubernetes/
├── README.md
├── deployment.yaml
├── service.yaml
├── configmap.yaml
└── network-policy.yaml
```

The repository contains the finalized manifests used for the main Kubernetes application.

Additional exercises are kept locally outside the repository in:

```text
~/tmp/
```

These files are practice material and are not part of the finalized repository configuration.

---

# Deployment

The application is deployed using a Kubernetes `Deployment`.

The Deployment:

* runs two Nginx replicas
* manages the desired number of Pods
* uses label selectors
* performs rolling updates
* maintains the desired state

Example:

```bash
kubectl apply -f kubernetes/deployment.yaml
```

Check the Deployment:

```bash
kubectl get deployments
```

Check the Pods:

```bash
kubectl get pods -o wide
```

Check Deployment details:

```bash
kubectl describe deployment webapp
```

## Desired State

Kubernetes continuously compares the actual cluster state with the desired state defined by the manifests.

For example, if one of the two Pods is deleted:

```bash
kubectl delete pod <pod-name>
```

the Deployment controller creates a replacement Pod automatically.

This demonstrates Kubernetes reconciliation.

---

# Service

The application is exposed using a Kubernetes `Service`.

```bash
kubectl apply -f kubernetes/service.yaml
```

Check the Service:

```bash
kubectl get service
```

Check endpoints:

```bash
kubectl get endpoints
```

The Service selects Pods using their labels.

This provides a stable network endpoint even when individual Pods are replaced.

---

# ConfigMap

Application configuration is stored in a `ConfigMap`.

```bash
kubectl apply -f kubernetes/configmap.yaml
```

Check the ConfigMap:

```bash
kubectl get configmap
```

Inspect it:

```bash
kubectl describe configmap webapp-config
```

The ConfigMap demonstrates separating application configuration from the container image.

A separate ConfigMap exercise was also created locally as:

```text
~/tmp/webapp-config.yaml
```

---

# Secrets

A Kubernetes Secret was practiced separately using:

```text
~/tmp/webapp-secret.yaml
```

The practice Secret contains a test password and is intentionally kept outside the repository.

Secrets should not be committed to Git in plaintext.

The repository `.gitignore` therefore excludes:

```text
kubernetes/secret.yaml
```

When testing a Secret-mounted environment variable, the value should not be printed. A safe verification is:

```bash
kubectl exec deploy/webapp -- \
  sh -c 'test -n "$DB_PASSWORD" && echo "DB_PASSWORD is set"'
```

---

# Health Probes

Kubernetes health probes were practiced using a separate local exercise:

```text
~/tmp/probe-demo.yaml
```

The exercise demonstrates:

* liveness probes
* readiness probes
* HTTP health checks
* probe failures
* container restarts
* traffic being removed from unhealthy Pods

A failed liveness probe can cause Kubernetes to restart a container.

A failed readiness probe removes the Pod from the Service endpoints without necessarily restarting the container.

---

# Resource Requests and Limits

Container resource management was practiced using:

```text
~/tmp/resources-demo.yaml
```

The Deployment in the main repository also defines resource requests and limits.

Requests describe the amount of CPU and memory required by a container.

Limits define the maximum amount of CPU and memory the container is allowed to use.

Example concept:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 64Mi
  limits:
    cpu: 500m
    memory: 128Mi
```

Check resource configuration:

```bash
kubectl describe pod <pod-name>
```

If Metrics Server is available:

```bash
kubectl top pods
```

---

# Rolling Updates and Rollbacks

The Deployment supports rolling updates.

Check rollout status:

```bash
kubectl rollout status deployment/webapp
```

View rollout history:

```bash
kubectl rollout history deployment/webapp
```

A previous revision can be restored using:

```bash
kubectl rollout undo deployment/webapp
```

This demonstrates one of the important Kubernetes operational capabilities: changing application versions while maintaining availability.

---

# Persistent Storage

Persistent storage was practiced as a separate Kubernetes exercise.

The following local manifests were used:

```text
~/tmp/webapp-pvc.yaml
~/tmp/storage-demo.yaml
```

The exercise demonstrated:

* PersistentVolumeClaims
* PersistentVolumes
* StorageClasses
* dynamic provisioning
* `ReadWriteOnce`
* `WaitForFirstConsumer`

The cluster dynamically provisioned persistent storage using the available local-path StorageClass.

The PVC initially remained `Pending` because the StorageClass uses `WaitForFirstConsumer`. After a Pod consumed the PVC, it became `Bound`.

Useful commands:

```bash
kubectl get pvc
kubectl get pv
kubectl get storageclass
```

This exercise helped demonstrate the difference between:

* application containers
* Pods
* ephemeral container storage
* persistent storage

The storage manifests remain practice material and are not currently finalized repository resources.

---

# Ingress

An NGINX Ingress Controller was installed in the local `kind` cluster.

An Ingress resource was practiced using:

```text
~/tmp/webapp-ingress.yaml
```

The exercise demonstrated HTTP routing for:

```text
webapp.local
```

Basic architecture:

```text
Client
  │
  ▼
Ingress Controller
  │
  ▼
Ingress
  │
  ▼
Service
  │
  ▼
Pods
```

The exercise demonstrated the distinction between:

* **Ingress** — defines HTTP/HTTPS routing rules
* **Ingress Controller** — implements the actual routing

Useful commands:

```bash
kubectl get ingress
kubectl describe ingress webapp
kubectl get pods -A
```

The Ingress configuration remains practice material rather than a finalized repository manifest.

---

# Namespaces and RBAC

A separate `development` Namespace was created to practice resource isolation and access control.

The RBAC exercises used:

```text
~/tmp/webapp-reader-role.yaml
~/tmp/webapp-reader-binding.yaml
```

The exercises demonstrated:

* Namespaces
* ServiceAccounts
* Roles
* RoleBindings
* permission checks

A Role was created to allow read access to Pods.

Permissions were tested using:

```bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:development:webapp-reader \
  -n development
```

This demonstrated basic Kubernetes RBAC.

The RBAC manifests remain practice material and are not currently finalized repository resources.

---

# NetworkPolicy

A NetworkPolicy was used to control Pod-to-Pod traffic.

The practice manifest is:

```text
~/tmp/server-policy.yaml
```

The exercise demonstrated how NetworkPolicy can restrict network communication between Pods based on labels.

Useful commands:

```bash
kubectl get networkpolicy -A
kubectl describe networkpolicy -n development
```

The repository also contains a finalized NetworkPolicy:

```text
kubernetes/network-policy.yaml
```

This manifest is part of the main Kubernetes application configuration.

---

# Troubleshooting Exercises

Several intentionally broken resources were created to practice Kubernetes troubleshooting.

## Broken Deployment

```text
~/tmp/broken-deployment.yaml
```

The exercise was used to investigate Deployment and Pod creation problems.

Useful commands:

```bash
kubectl get deployment
kubectl get pods
kubectl describe deployment broken-nginx
kubectl describe pod <pod-name>
kubectl get events
```

---

## CrashLoopBackOff

```text
~/tmp/crash-deployment.yaml
```

This exercise demonstrates a container repeatedly starting and failing.

Useful commands:

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

`--previous` is particularly useful when the current container has already restarted.

---

## Broken Service

```text
~/tmp/broken-service.yaml
```

This exercise demonstrates troubleshooting a Service that does not correctly reach its Pods.

Useful commands:

```bash
kubectl get service
kubectl describe service broken-nginx-service
kubectl get endpoints
kubectl get pods --show-labels
```

A common troubleshooting approach is:

```text
Service
  ↓
Selector
  ↓
Pod labels
  ↓
Endpoints
  ↓
Pod
```

---

## Probe Failures

```text
~/tmp/probe-demo.yaml
```

This exercise demonstrates how failed health checks affect Pods and Services.

Useful commands:

```bash
kubectl describe pod <pod-name>
kubectl get events
kubectl get endpoints
kubectl logs <pod-name>
```

---

# What I Practiced

## Core Kubernetes

* Kubernetes architecture and resources
* `kubectl`
* YAML manifests
* Deployments
* Pods
* Services
* Labels and selectors
* Desired-state reconciliation
* Rolling updates
* Rollbacks

## Configuration and Application Health

* ConfigMaps
* Secrets
* Environment variables
* Liveness probes
* Readiness probes
* Resource requests and limits

## Storage and Networking

* PersistentVolumeClaims
* PersistentVolumes
* StorageClasses
* Dynamic provisioning
* `WaitForFirstConsumer`
* Services
* Ingress
* NGINX Ingress Controller
* NetworkPolicy

## Security and Access Control

* Namespaces
* ServiceAccounts
* Roles
* RoleBindings
* RBAC
* `kubectl auth can-i`
* Kubernetes Secrets
* NetworkPolicy

## Troubleshooting

* Deployment failures
* Pod failures
* `CrashLoopBackOff`
* Container logs
* Previous container logs
* Service selector problems
* Endpoint troubleshooting
* Probe failures
* Kubernetes events
* Resource inspection

---

# Useful Commands

Check cluster:

```bash
kubectl cluster-info
kubectl get nodes
```

List resources:

```bash
kubectl get all
kubectl get pods
kubectl get deployments
kubectl get services
```

Detailed information:

```bash
kubectl describe pod <pod-name>
kubectl describe deployment webapp
kubectl describe service webapp
```

Logs:

```bash
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

Events:

```bash
kubectl get events --sort-by=.lastTimestamp
```

Execute a command inside a container:

```bash
kubectl exec -it <pod-name> -- sh
```

Check labels:

```bash
kubectl get pods --show-labels
```

Check Service endpoints:

```bash
kubectl get endpoints
```

Check RBAC permissions:

```bash
kubectl auth can-i get pods
```

Check NetworkPolicy:

```bash
kubectl get networkpolicy -A
```

---

# Verification

Apply the main repository manifests:

```bash
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/network-policy.yaml
```

Check the resulting resources:

```bash
kubectl get all
```

Check Pods:

```bash
kubectl get pods -o wide
```

Check the Service:

```bash
kubectl get service webapp
```

Check the NetworkPolicy:

```bash
kubectl get networkpolicy
```

Check Deployment rollout:

```bash
kubectl rollout status deployment/webapp
```

---

# Practice Material

Additional Kubernetes exercises are kept locally outside the repository in:

```text
~/tmp/
```

Current practice manifests:

```text
~/tmp/
├── broken-deployment.yaml
├── broken-service.yaml
├── crash-deployment.yaml
├── probe-demo.yaml
├── resources-demo.yaml
├── server-policy.yaml
├── storage-demo.yaml
├── webapp-config.yaml
├── webapp-ingress.yaml
├── webapp-pvc.yaml
├── webapp-reader-binding.yaml
├── webapp-reader-role.yaml
├── webapp-secret.yaml
└── webapp.yaml
```

These files contain practice manifests for troubleshooting, probes, resources, persistent storage, Ingress, RBAC, configuration, networking, and Secrets.

They are intentionally kept outside the repository's finalized Kubernetes manifests. Individual exercises can later be promoted into the project after they are cleaned up, generalized, and made reusable.

---

# Key Learning Outcome

This lab provided practical experience with the Kubernetes workflow:

```text
Define
  ↓
Deploy
  ↓
Expose
  ↓
Configure
  ↓
Observe
  ↓
Troubleshoot
  ↓
Secure
  ↓
Update
  ↓
Rollback
```

The main goal was not simply to deploy an Nginx container, but to understand how Kubernetes manages applications and how an engineer investigates problems when the desired state is not achieved.
