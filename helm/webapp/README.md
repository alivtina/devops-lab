# Helm Web Application

A hands-on Helm project demonstrating how to package, configure, validate, and deploy a Kubernetes web application.

The chart deploys an Nginx application and demonstrates how Helm templates Kubernetes manifests and separates deployment configuration from reusable templates.

## Goal

Use Helm to manage a Kubernetes application through a reusable chart instead of maintaining fully static Kubernetes manifests.

The project demonstrates:

* Helm chart structure
* templating
* configurable values
* Kubernetes Deployments and Services
* chart validation
* release management
* upgrades
* rollbacks

## Prerequisites

The project requires:

* Kubernetes cluster
* `kubectl`
* Helm 3+

The chart was developed and tested against a local Kubernetes environment.

For example, the chart can be deployed to a `kind` cluster.

Verify the tools:

```bash
kubectl version --client
helm version
kubectl cluster-info
```

## Chart Structure

```text
webapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml
```

### Chart.yaml

Defines the chart metadata:

* Chart name: `webapp`
* Chart type: `application`
* Chart version: `0.1.0`
* Application version: `1.0`

### values.yaml

Contains configurable deployment values:

```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.29-alpine"

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    cpu: 100m
    memory: 64Mi
  limits:
    cpu: 500m
    memory: 128Mi
```

These values are consumed by the Helm templates to generate the final Kubernetes manifests.

---

## Kubernetes Resources

The chart creates two Kubernetes resources.

### Deployment

The Deployment:

* runs the configured number of replicas
* uses the configured container image
* exposes container port `80`
* applies CPU and memory requests and limits
* uses the Helm release name for resource naming and labels

With the default values:

```text
2 replicas
nginx:1.29-alpine
```

### Service

The Service:

* uses `ClusterIP` by default
* exposes port `80`
* selects Pods using the Helm release label
* forwards traffic to container port `80`

The `ClusterIP` Service is intended for internal cluster access.

---

## Helm Workflow

The basic workflow for this project is:

```text
Chart
  ↓
helm lint
  ↓
helm template
  ↓
helm install
  ↓
helm upgrade
  ↓
helm history
  ↓
helm rollback
  ↓
helm uninstall
```

This demonstrates the lifecycle of a Helm-managed Kubernetes application.

---

## Validate the Chart

Run Helm lint:

```bash
helm lint helm/webapp
```

Render the Kubernetes manifests without installing them:

```bash
helm template webapp helm/webapp
```

This allows the generated Kubernetes YAML to be inspected before deployment.

---

## Install the Chart

Install the chart into the current Kubernetes cluster:

```bash
helm install webapp helm/webapp
```

Check the Helm release:

```bash
helm list
```

Check the generated Kubernetes resources:

```bash
kubectl get deployment,service,pods
```

Check the release status:

```bash
helm status webapp
```

---

## Access the Application

The default Service type is `ClusterIP`, so the application is not exposed directly outside the cluster.

For local testing, use port forwarding:

```bash
kubectl port-forward service/webapp 8080:80
```

Then, in another terminal:

```bash
curl http://localhost:8080
```

Expected response:

```text
Welcome to nginx!
```

This demonstrates the complete path:

```text
localhost:8080
      ↓
kubectl port-forward
      ↓
Kubernetes Service
      ↓
Nginx Pod
```

---

## Customize Values

Helm allows values to be overridden without modifying the chart templates.

For example, deploy three replicas:

```bash
helm install webapp helm/webapp \
  --set replicaCount=3
```

Or create a custom values file:

```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.29-alpine"
```

Then install with:

```bash
helm install webapp helm/webapp \
  -f custom-values.yaml
```

This demonstrates how the same chart can be reused with different deployment configurations.

---

## Upgrade

After changing configuration, upgrade the existing release:

```bash
helm upgrade webapp helm/webapp
```

Check the resulting Pods:

```bash
kubectl get pods
```

Check the release revision:

```bash
helm history webapp
```

---

## Rollback

Helm keeps release history, allowing a previous revision to be restored.

View release history:

```bash
helm history webapp
```

Rollback to a previous revision:

```bash
helm rollback webapp <REVISION>
```

Check the release:

```bash
helm status webapp
```

This demonstrates a basic deployment recovery workflow.

---

## Uninstall

Remove the Helm release:

```bash
helm uninstall webapp
```

Verify that the resources were removed:

```bash
kubectl get deployment,service,pods
```

---

## Useful Commands

Inspect chart metadata:

```bash
helm show chart helm/webapp
```

Inspect default values:

```bash
helm show values helm/webapp
```

Render manifests:

```bash
helm template webapp helm/webapp
```

Inspect rendered manifests:

```bash
helm template webapp helm/webapp | less
```

Check Helm releases:

```bash
helm list
```

Check release status:

```bash
helm status webapp
```

---

## Learning Outcome

After completing this project, I can independently:

* understand the structure of a Helm chart
* define configurable values in `values.yaml`
* use Helm templates to generate Kubernetes manifests
* validate a chart with `helm lint`
* preview generated manifests with `helm template`
* deploy Kubernetes resources using Helm
* override chart values
* access an internally exposed Kubernetes application
* upgrade a Helm release
* inspect release history
* roll back a release
* remove a Helm release
* explain the role of Helm in Kubernetes application deployment

This project provides the foundation for managing more complex Kubernetes applications and deployment workflows.
