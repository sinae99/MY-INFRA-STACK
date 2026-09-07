# observability : Prometheus + Grafana + Alertmanager

Chart: `prometheus-community/kube-prometheus-stack`  
Namespace: `monitoring`  
Release: `cluster-monitoring`


---


## 1. ns

```bash
kubectl create ns monitoring
```

---

## 2. Helm repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

## 3. Helm install

```bash
cd observability

helm install cluster-monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values.yaml
```

---

## 4. verify

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

Expect Running: prometheus-operator, prometheus, grafana, alertmanager.

---

## 5. access (port-forwards + credentials)

```bash
./start-port-forwards.sh
./credentials.sh
```

| UI | URL |
|----|-----|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Alertmanager | http://localhost:9093 |

Stop:

```bash
./stop-port-forwards.sh
```

---

## files

| File | Purpose |
|------|---------|
| `values.yaml` | Helm values |
| `dashboards/nodes-overview.json` | Grafana: nodes status / CPU / RAM / pods |
| `dashboards/geoapi-overview.json` | Grafana: GeoAPI health / traffic / cache / runtime |
| `credentials.sh` | Print Grafana admin user/password |
| `start-port-forwards.sh` | Port-forward Prometheus / Grafana / Alertmanager |
| `stop-port-forwards.sh` | Stop those port-forwards |
