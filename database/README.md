# database : CNPG (primary + replica)

Operator: **CloudNativePG 1.30.0**  
Operator namespace: `cnpg-system`  
Postgres namespace: `postgres`  
Cluster: `sina-db` (2 instances)  
App DB / user: `geoapi`  
StorageClass: `local-path`

| Component | Role |
|-----------|------|
| CNPG operator | CRDs + manages Postgres clusters |
| `sina-db` primary | Read/write for `geoapi` |
| `sina-db` replica | Streaming standby on the other worker |
| `sina-db-rw` | Service → primary |
| `sina-db-ro` | Service → replicas |


---

## 1. install operator

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.30/releases/cnpg-1.30.0.yaml
```

Verify:

```bash
kubectl get pods -n cnpg-system
```

---

## 2. ns

```bash
kubectl create ns postgres
```

---

## 3. deploy cluster

```bash
cd database
kubectl apply -f cluster.yaml
```

---

## 4. verify

```bash
kubectl get cluster -n postgres
kubectl get pods -n postgres -o wide
kubectl get pvc -n postgres
kubectl get svc -n postgres
```

Expect:

- Cluster `sina-db` healthy
- Pods `sina-db-1` and `sina-db-2` Running on **different** workers (`vm2` / `vm3`)
- PVCs Bound (`local-path`)
- Services: `sina-db-rw`, `sina-db-ro`, `sina-db-r`

---

## 5. creds

```bash
./credentials.sh
```

Prints user/password from secret `sina-db-app` (database `geoapi`).

---

## 6. test

```bash
kubectl exec -n postgres -it sina-db-1 -- \
  psql -U geoapi -d geoapi -c 'SELECT version();'
```

---

## 7. connection for geoapi

| Setting | Value |
|---------|-------|
| Host | `sina-db-rw.postgres.svc.cluster.local` |
| Port | `5432` |
| Database | `geoapi` |
| User / Pass | `./credentials.sh` |

---

## files

| File | Purpose |
|------|---------|
| `cluster.yaml` | CNPG Cluster `sina-db` (primary + replica) |
| `credentials.sh` | Print `geoapi` DB user/password from `sina-db-app` |

