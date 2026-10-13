# Vault and External Secrets Operator Lab

## Goal

Practice managing application secrets outside Kubernetes using HashiCorp Vault and External Secrets Operator (ESO).

This lab demonstrates:

- Storing secrets in Vault KV v2.
- Authenticating ESO to Vault using Kubernetes authentication.
- Applying a scoped Vault policy.
- Synchronizing Vault values into a Kubernetes Secret.
- Testing secret rotation and container environment variables.
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
        |
        +-- DEMO_USERNAME
        +-- DEMO_PASSWORD
```

## Environment

- Host: Arch Linux
- Kubernetes: local kind cluster
- Vault namespace: `vault`
- ESO namespace: `external-secrets`
- Application namespace: `webapp`
- Vault service: `vault.vault.svc:8200`
- Secret engine: KV v2 mounted at `secret/`
- ESO Helm chart version: `2.12.0`

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

The purpose of this experiment was to test what happens when a secret changes in Vault.

The test workflow was:

1. Update the username stored in Vault.
2. Trigger an ESO reconciliation.
3. Verify that the Kubernetes Secret receives the new value.
4. Compare the synchronized Secret with the environment variable in the running container.

### Update the Vault secret

Example using disposable test data:

```bash
kubectl exec -n vault vault-0 -- sh -c '
  export VAULT_TOKEN=root
  vault kv patch -mount=secret webapp-demo username=rotation-test-003
'
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

The experiment confirmed that ESO updated the Kubernetes Secret with the new username.

## 4. Kubernetes Secret Environment Variables

The test Deployment is defined in:

`kubernetes/secret-consumer.yaml`

It injects the synchronized Secret into a container through `secretKeyRef`:

- `DEMO_USERNAME`
- `DEMO_PASSWORD`

### Verify that both variables exist

```bash
kubectl exec -n webapp deployment/secret-consumer -- sh -c '
  test -n "$DEMO_USERNAME" &&
  test -n "$DEMO_PASSWORD" &&
  echo "Both secret environment variables are present"
'
```

This checks that both variables are present without printing their values.

### Important behavior

Updating a Kubernetes Secret does not automatically change environment variables inside an already-running container.

The experiment demonstrated:

1. Vault's username was updated.
2. ESO synchronized the new value into `webapp-demo-secret`.
3. The existing container continued to use the previous username.
4. The Deployment was restarted.
5. The replacement container loaded the updated username.

### Manually restart the Deployment

```bash
kubectl rollout restart deployment/secret-consumer -n webapp
kubectl rollout status deployment/secret-consumer -n webapp
```

Verify that the replacement container received the new value without printing it:

```bash
kubectl exec -n webapp deployment/secret-consumer -- sh -c '
  test "$DEMO_USERNAME" = "rotation-test-003" &&
  echo "Updated username is loaded"
'
```

The experiment verified manual rotation. **Automatic rollout on Secret changes has not yet been implemented.**

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

Potential causes of synchronization failures include:

- Vault service unavailable.
- Incorrect Kubernetes authentication configuration.
- Incorrect ServiceAccount or Vault role binding.
- Missing Vault policy permissions.
- Incorrect KV v2 path or property names.
- Expired or invalid Vault tokens.
- ESO permission problems.
- SecretStore or ExternalSecret not Ready.

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
- A tested secret-rotation strategy.

## 7. Planned Improvements

1. Implement automatic Deployment rollouts when `webapp-demo-secret` changes.
2. Verify the full Vault → ESO → Kubernetes Secret → Pod rotation workflow.
3. Review ESO's effective Kubernetes RBAC permissions.
4. Replace Vault development mode with an appropriately secured persistent configuration.
5. Configure TLS and review token lifetimes and Vault policies.
6. Repeat the rotation test after security improvements.

## 8. Learning Outcomes

### Demonstrated

- Configured a Vault KV v2 secret source.
- Used Kubernetes authentication instead of the old static Vault token.
- Configured a dedicated Kubernetes ServiceAccount and Vault role.
- Applied a narrowly scoped Vault read policy.
- Synchronized Vault properties into a Kubernetes Secret using ESO.
- Verified Secret synchronization without printing credentials.
- Tested secret rotation.
- Demonstrated why environment variables do not update inside an existing container.
- Restarted a Deployment and verified the replacement container's configuration.
- Identified limitations in the lab's authentication, storage, transport security, and RBAC.

### Current progress

**Level: Developing**

The core synchronization and manual rotation workflow has been tested successfully.

Automatic rollouts, production-grade Vault configuration, and a complete least-privilege RBAC review remain outstanding.

The next stage is to automate workload rollouts and verify the entire rotation workflow without a manual restart.
