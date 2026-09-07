# test-api

```bash
kubectl -n geoapi port-forward svc/geoapi 8080:80
```

```bash
curl -sS http://127.0.0.1:8080/health
curl -sS http://127.0.0.1:8080/metrics | grep iploc_
curl -sS "http://127.0.0.1:8080/iploc?ip=8.8.8.8"
curl -sS "http://127.0.0.1:8080/iploc?ip=8.8.8.8"
curl -sS "http://127.0.0.1:8080/iploc?ip=1.1.1.1"
curl -sS http://127.0.0.1:8080/metrics | grep iploc_
```

```bash
kubectl -n postgres exec -it sina-db-1 -- \
  psql -U postgres -d geoapi -c 'SELECT * FROM ip_cache ORDER BY ip;'

kubectl -n postgres exec -it sina-db-1 -- \
  psql -U postgres -d geoapi -c 'SELECT COUNT(*) AS cached_ips FROM ip_cache;'

kubectl -n postgres exec -it sina-db-1 -- \
  psql -U postgres -d geoapi -c \
  "INSERT INTO ip_cache (ip, country) VALUES ('9.9.9.9', 'sinaLand') ON CONFLICT (ip) DO NOTHING;"

curl -sS "http://127.0.0.1:8080/iploc?ip=9.9.9.9"
```
