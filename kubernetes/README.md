# Kubernetes Lab

## Goal

Practice the fundamentals of deploying and exposing a containerized application with Kubernetes using a local `kind` cluster.

## Architecture

```text
Arch Linux host
    │
    │ NodePort :31757
    ▼
Kind Kubernetes node
    │
    ▼
Service: nginx-deployment
    │
    ├── Pod: nginx
    └── Pod: nginx
```

The Service selects Pods using the label:

```text
app=nginx-deployment
```

## Deployment

The application is managed by a Kubernetes Deployment with:

* 2 replicas
* Nginx container
* `nginx:1.29-alpine` image
* Container port `80`

The Deployment ensures that the desired number of Pods is maintained.

## Service

A `NodePort` Service exposes the Nginx Pods.

* Service port: `80`
* Target port: `80`
* NodePort: dynamically assigned by Kubernetes

The Service uses a label selector to route traffic only to the Pods belonging to the `nginx-deployment`.

## What I Practiced

* Created a local Kubernetes cluster with `kind`
* Created a Deployment using YAML
* Created a Service using YAML
* Used labels and selectors to connect Services to Pods
* Inspected Pod IP addresses and EndpointSlices
* Tested Service connectivity from inside the cluster
* Tested NodePort connectivity from the host
* Scaled a Deployment from 2 to 3 replicas
* Practiced Kubernetes desired-state reconciliation
* Performed a rolling update from `nginx:alpine` to `nginx:1.29-alpine`
* Verified the resulting Pods and deployment state

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
