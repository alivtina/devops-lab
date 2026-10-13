# Vault and External Secrets Operator Lab

## Goal

Practice managing application secrets outside Kubernetes using HashiCorp Vault and External Secrets Operator (ESO).

This lab demonstrates:

- Storing secrets in Vault KV v2.
- Authenticating ESO to Vault using Kubernetes authentication.
- Applying a scoped Vault policy.
- Synchronizing Vault values into a Kubernetes Secret.
- Understanding how Kubernetes Secret changes affect container environment variables.
- Automatically restarting a workload with Stakater Reloader when its Secret changes.
- Identifying security limitations and improvements needed before production.

This is a local learning environment, not a production deployment.

## Architecture

```text
HashiCorp Vault (KV v2)
        |
        | Kubernetes authentication
        | Vault role: webapp-vault-auth
        | Policy: eso-webapp
        v
External Secrets Operator (ESO)
        |
        | SecretStore: vault-backend
        | ExternalSecret: webapp-demo
        v
Kubernetes Secret: webapp-demo-secret
        |
        | secretKeyRef
        v
Deployment: secret-consumer
        ^
        |
Stakater Reloader
        |
        | Watches the annotated Secret
        | Triggers a Deployment rollout
        v
Replacement pod loads updated environment variables
        |
        +-- DEMO_USERNAME
        +-- DEMO_PASSWORD
```

## Environment

- Host: Arch Linux
- Kubernetes: local kind cluster
- Vault namespace: `vault`
- ESO namespace: `external-secrets`
- Reloader namespace: `reloader`
- Application namespace: `webapp`
- Vault service: `vault.vault.svc:8200`
- Secret engine: KV v2 mounted at `secret/`
- ESO Helm chart version: `2.12.0`
- Stakater Reloader chart version: `2.2.18`
- Stakater Reloader application version: `v1.4.22`

Vault currently runs in development mode with in-memory storage. Its secrets, policies, and tokens may be lost when the server is recreated.

## 1. Vault Kubernetes Authentication

ESO authenticates to Vault using Kubernetes authentication instead of a static Vault token stored in a Kubernetes Secret.

The namespaced SecretStore is defined in:

`kubernetes/secretstore-vault.yaml`

Important settings:

- Authentication method: Kubernetes
- Auth mount: `kubernetes`
- Vault role: `webapp-vault-auth`
- Kubernetes ServiceAccount: `vault-auth`
- ServiceAccount token audience: `vault`

The Vault role binds the `vault-auth` ServiceAccount in the `webapp` namespace.

The role issues Vault tokens with a one-hour TTL.

### Vault policy

The `eso-webapp` policy grants read access to the test secret:

```hcl
path "secret/data/webapp-demo" {
  capabilities = ["read"]
}
```

This is a KV v2 API data path. The policy allows reading this specific secret rather than granting access to every secret in the Vault mount.

The Vault auth method, role, and policy are configured separately from the Kubernetes SecretStore manifest.

### Migration from static-token authentication

The original SecretStore used a Kubernetes Secret named `vault-eso-token` containing a Vault token.

The configuration was migrated to Kubernetes authentication. After verifying that the SecretStore and ExternalSecret remained healthy, the old `vault-eso-token` Secret was deleted.

This removed the need for ESO to depend on that static Vault token.

## 2. External Secrets Operator

The ExternalSecret manifest is:

`kubernetes/external-secret-webapp.yaml`

It reads two properties from the Vault key `webapp-demo`:

- `username`
- `password`

ESO synchronizes these values into the Kubernetes Secret:

`webapp-demo-secret`

Configuration:

- Refresh interval: `1h`
- Creation policy: `Owner`
- Deletion policy: `Retain`

The SecretStore became Ready, and the ExternalSecret successfully synchronized the requested values.

### Verification

Check the SecretStore:

```bash
kubectl get secretstore vault-backend -n webapp
```

Check the ExternalSecret:

```bash
kubectl get externalsecret webapp-demo -n webapp
```

List the target Secret's key names without printing their values:

```bash
kubectl get secret webapp-demo-secret -n webapp \
  -o go-template='{{range $k, $v := .data}}{{printf "%s\n" $k}}{{end}}'
```

Expected key names:

```text
password
username
```

Never commit actual credentials, Vault tokens, or unredacted Secret manifests to Git.

## 3. Secret Rotation Experiment

The purpose of this experiment was to verify the complete secret-rotation workflow:

1. Update the username stored in Vault.
2. Trigger an ESO reconciliation.
3. Confirm that ESO synchronizes the updated value into the Kubernetes Secret.
4. Allow Reloader to detect the Secret change.
5. Confirm that Kubernetes replaces the consumer pod.
6. Verify that the replacement container loads the updated environment variable.

### Update the Vault secret

Example using disposable test data:

```bash
kubectl exec -n vault vault-0 -- \
  vault kv patch secret/webapp-demo username=rotation-test-003
```

This updates the username while preserving other existing properties in the KV v2 secret.

The example value is test data. Do not use real credentials in shell history or shared logs.

### Trigger ESO synchronization

```bash
kubectl annotate externalsecret webapp-demo -n webapp \
  force-sync="$(date +%s)" --overwrite
```

Check the synchronization status:

```bash
kubectl get externalsecret webapp-demo -n webapp
```

For a more explicit status check:

```bash
kubectl get externalsecret webapp-demo -n webapp \
  -o custom-columns='NAME:.metadata.name,READY:.status.conditions[0].status,STATUS:.status.conditions[0].reason,SYNCED:.status.refreshTime'
```

The experiment confirmed that ESO reported `Ready=True` and `SecretSynced` after the update.

## 4. Automatic Workload Rollouts with Stakater Reloader

Updating a Kubernetes Secret does not automatically change environment variables inside an already-running container.

Environment variables sourced from a Secret are established when the container starts. A replacement pod is needed to load the updated values.

Stakater Reloader automates this restart when a watched Kubernetes Secret changes.

### Installation

Reloader was installed through Helm:

```bash
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo update stakater

helm upgrade --install reloader stakater/reloader \
  --namespace reloader \
  --create-namespace \
  --set reloader.watchGlobally=false \
  --set 'reloader.namespaces={webapp}'
```

The installation is configured to watch the `webapp` namespace and its own `reloader` namespace, rather than watching every namespace in the cluster.

Verify the Deployment:

```bash
kubectl get deployment reloader-reloader -n reloader
```

Expected status: one available replica.

### Configure the watched Secret

The test Deployment is defined in:

`kubernetes/secret-consumer.yaml`

Its metadata includes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-consumer
  namespace: webapp
  annotations:
    secret.reloader.stakater.com/reload: "webapp-demo-secret"
```

The annotation explicitly identifies `webapp-demo-secret` as the Secret that should trigger a rollout of this Deployment.

This configuration avoids enabling automatic reloads for every workload.

### Verify the rollout

After updating Vault and triggering ESO synchronization, check the Deployment:

```bash
kubectl rollout status deployment/secret-consumer -n webapp --timeout=30s
```

To verify that the pod was replaced, compare pod UIDs before and after the Secret update:

```bash
kubectl get pods -n webapp -l app=secret-consumer \
  -o custom-columns='NAME:.metadata.name,UID:.metadata.uid,STATUS:.status.phase,CREATED:.metadata.creationTimestamp'
```

A changed UID indicates that the old pod was replaced.

Finally, verify that the new container received the updated username without printing its value:

```bash
kubectl exec -n webapp deployment/secret-consumer -- sh -c '
  test "$DEMO_USERNAME" = "rotation-test-003" &&
  echo "SUCCESS: updated username is loaded" ||
  echo "FAIL: username does not match expected value"
'
```

### Verified result

The end-to-end experiment succeeded:

1. The username was updated in Vault KV v2.
2. ESO reported `Ready=True` and `SecretSynced`.
3. The `secret-consumer` pod UID changed, confirming replacement.
4. The replacement pod was Running.
5. The environment-variable check confirmed that the updated username was loaded.

The test therefore demonstrated the following workflow:

**Vault → ESO → Kubernetes Secret → Reloader → replacement pod → updated environment variable.**

This verifies automatic rollout for the `secret-consumer` Deployment in the local lab. It does not establish zero-downtime rotation for every application. Availability depends on factors such as replica count, readiness probes, rollout strategy, and application behavior.

The test Deployment is a dedicated lab workload. The existing three-replica NGINX application Deployment was not modified for this experiment.

## 5. Troubleshooting

Inspect the SecretStore:

```bash
kubectl describe secretstore vault-backend -n webapp
```

Inspect the ExternalSecret:

```bash
kubectl describe externalsecret webapp-demo -n webapp
```

Check recent namespace events:

```bash
kubectl get events -n webapp --sort-by=.lastTimestamp
```

Inspect ESO logs:

```bash
kubectl logs -n external-secrets deployment/external-secrets
```

Inspect Reloader logs:

```bash
kubectl logs -n reloader deployment/reloader-reloader --since=10m
```

Potential causes of synchronization failures include:

- Vault service unavailable.
- Incorrect Kubernetes authentication configuration.
- Incorrect ServiceAccount or Vault role binding.
- Missing Vault policy permissions.
- Incorrect KV v2 path or property names.
- Expired or invalid Vault tokens.
- ESO permission problems.
- SecretStore or ExternalSecret not Ready.

If the Kubernetes Secret changes but no rollout occurs, check:

- Reloader Deployment health and logs.
- Reloader namespace scope and RBAC.
- The `secret.reloader.stakater.com/reload` annotation.
- Whether the annotation references the correct Secret name.
- Whether the ExternalSecret actually caused the Kubernetes Secret to change.

Never paste secret values, Vault tokens, or unredacted Secret manifests into troubleshooting reports.

## 6. Security Limitations

This lab is intended for learning and is not production-ready.

### Vault development mode

Vault runs in development mode with in-memory storage. This is useful for disposable experiments but unsuitable for persistent production secrets.

### HTTP instead of TLS

The Vault service is accessed over HTTP inside the local cluster. A production deployment requires an appropriately configured TLS setup and certificate validation.

### Root token

Administrative lab commands use the Vault development root token. Production workloads should not use a root token for routine operations.

### Kubernetes RBAC

The ESO controller's installed ClusterRole grants permission to create `serviceaccounts/token`.

Kubernetes RBAC permissions are additive. A narrower namespace Role does not restrict permissions already granted by a broader ClusterRole.

The effective permissions therefore require further review before this configuration can be considered least-privilege.

Reloader is configured with namespace-scoped roles rather than cluster-wide workload access. Its Role in the `webapp` namespace grants access to Secrets and ConfigMaps and permits updates to several workload types.

The following authorization checks were verified for the `reloader-reloader` ServiceAccount in the `reloader` namespace:

| Check | Result |
|---|---|
| Patch Deployments in `webapp` | Allowed |
| Read Secrets in `webapp` | Allowed |
| Read Secrets in `default` | Denied |
| List Secrets across all namespaces | Denied |

These checks support the intended namespace-scoped design, but do not constitute a complete RBAC audit. Reloader can read and watch Secrets throughout `webapp`, not only the Secret referenced by the test Deployment. Its additional Job, CronJob, and workload permissions should be reviewed against the deployed chart's requirements before production use.

### Kubernetes Secrets

Kubernetes Secret values are base64-encoded in API representations. Base64 is not encryption.

Production environments should consider:

- Encryption at rest.
- Restricted RBAC permissions.
- TLS for service communication.
- Short-lived workload authentication.
- Least-privilege Vault policies.
- Audit logging.
- Persistent storage, backups, and recovery.
- Tested secret-rotation and recovery procedures.
- Monitoring and alerting for failed secret synchronization.

### Rotation is not revocation

Replacing a pod makes it load the latest Secret values, but this alone does not revoke old credentials in the upstream system. A complete production rotation process must also account for credential validity, revocation, application connection pools, and recovery if the new credential fails.

## 7. Planned Improvements

1. Review ESO's effective Kubernetes RBAC permissions.
2. Replace Vault development mode with an appropriately secured persistent configuration.
3. Configure TLS and review token lifetimes and Vault policies.
4. Test failure and recovery scenarios, including Vault unavailability and ESO synchronization errors.
5. Test application availability and rollout behavior with multiple replicas.
6. Validate credential revocation and recovery procedures.

## 8. Learning Outcomes

### Demonstrated

- Configured a Vault KV v2 secret source.
- Used Kubernetes authentication instead of the old static Vault token.
- Configured a dedicated Kubernetes ServiceAccount and Vault role.
- Applied a narrowly scoped Vault read policy.
- Synchronized Vault properties into a Kubernetes Secret using ESO.
- Verified Secret synchronization without printing credentials.
- Explained why environment variables do not update inside an existing container.
- Installed Stakater Reloader using Helm.
- Configured namespace scope and an explicit Secret reload annotation.
- Verified automatic Deployment rollout after an ESO-synchronized Secret update.
- Confirmed that the replacement pod loaded the updated username without exposing credentials.
- Identified limitations in authentication, storage, transport security, RBAC, and credential rotation.

### Current progress

**Level: Developing**

The local lab has demonstrated the complete Vault KV v2 → ESO → Kubernetes Secret → Reloader → replacement pod workflow.

Automatic rollout is verified for the dedicated `secret-consumer` Deployment. Production-grade Vault configuration, a complete least-privilege RBAC review, and failure/recovery testing remain outstanding.

The next stage is to review the effective permissions and strengthen the lab's security configuration before treating this as a production-style implementation.
