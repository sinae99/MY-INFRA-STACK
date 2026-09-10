# cicd : GitHub Actions + GHCR

```
git push → pytest → docker build → ghcr.io/<your-github-user>/geoapi → kubectl apply
```

Workflow: [`.github/workflows/geoapi.yml`](../.github/workflows/geoapi.yml)

## flow

| Step | What |
|------|------|
| test | `pytest` in `api/` |
| build-push | `ghcr.io/<your-github-user>/geoapi:<sha>` + `:latest` |
| deploy | apply `api/k8s/` |


## Secrets

| Secret | Source |
|--------|--------|
| `KUBECONFIG` | Add the contents of your kubeconfig as a GitHub Actions secret |
| `GITHUB_TOKEN` | Automatic (GHCR push) |


## Private GHCR

Cluster pull uses [`api/k8s/secret-ghcr.yaml`](../api/k8s/secret-ghcr.yaml) (`ghcr-cred`).


## Deploy manifests

```bash
kubectl apply -f api/k8s/namespace.yaml
kubectl apply -f api/k8s/secret.yaml
kubectl apply -f api/k8s/secret-ghcr.yaml
kubectl apply -f api/k8s/deployment.yaml
kubectl apply -f api/k8s/service.yaml
kubectl apply -f api/k8s/servicemonitor.yaml
```
