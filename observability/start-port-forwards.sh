#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="monitoring"

svc_by_label() {
  local label="$1"
  kubectl -n "${NAMESPACE}" get svc -l "${label}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true
}

# kube-prometheus-stack labels prometheus/alertmanager as app=..., grafana as app.kubernetes.io/name=
PROM_SVC=$(svc_by_label "app=kube-prometheus-stack-prometheus")
GRAF_SVC=$(svc_by_label "app.kubernetes.io/name=grafana")
AM_SVC=$(svc_by_label "app=kube-prometheus-stack-alertmanager")

if [[ -z "${PROM_SVC}" || -z "${GRAF_SVC}" || -z "${AM_SVC}" ]]; then
  echo "Could not find services in ${NAMESPACE}."
  echo "  prometheus:   ${PROM_SVC:-missing}"
  echo "  grafana:      ${GRAF_SVC:-missing}"
  echo "  alertmanager: ${AM_SVC:-missing}"
  echo "Is the stack installed? kubectl get svc -n ${NAMESPACE}"
  exit 1
fi

echo "Starting port-forwards in background..."
echo "  Prometheus:   http://localhost:9090  (svc/${PROM_SVC})"
echo "  Grafana:      http://localhost:3000  (svc/${GRAF_SVC})"
echo "  Alertmanager: http://localhost:9093  (svc/${AM_SVC})"

kubectl -n "${NAMESPACE}" port-forward "svc/${PROM_SVC}" 9090:9090 >/tmp/pf-prometheus.log 2>&1 &
echo $! > /tmp/pf-prometheus.pid

kubectl -n "${NAMESPACE}" port-forward "svc/${GRAF_SVC}" 3000:80 >/tmp/pf-grafana.log 2>&1 &
echo $! > /tmp/pf-grafana.pid

kubectl -n "${NAMESPACE}" port-forward "svc/${AM_SVC}" 9093:9093 >/tmp/pf-alertmanager.log 2>&1 &
echo $! > /tmp/pf-alertmanager.pid

echo "Done."
echo "Credentials: ./credentials.sh"
echo "To stop:     ./stop-port-forwards.sh"
