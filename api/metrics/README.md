# api metrics

path: `GET /metrics`

scrape the geoapi service :

```bash
kubectl apply -f api/k8s/servicemonitor.yaml
```

---

## Metric

| Metric | Type | Meaning |
|--------|------|---------|
| `iploc_requests_total` | Counter | Total `/iploc` calls |
| `iploc_cached_ips` | Gauge | Rows in `ip_cache` (`SELECT COUNT(*)`) |

---


## Files

| File | Role |
|------|------|
| [`../app.py`](../app.py) | Emits the two metrics |
| [`../k8s/servicemonitor.yaml`](../k8s/servicemonitor.yaml) | Prometheus scrape |
