#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="monitoring"

SECRET_NAME=$(kubectl -n "${NAMESPACE}" get secret \
  -l app.kubernetes.io/name=grafana \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [[ -z "${SECRET_NAME}" ]]; then
  echo "Could not find Grafana secret in namespace ${NAMESPACE}"
  echo "Try: kubectl get secret -n ${NAMESPACE} | grep grafana"
  exit 1
fi

USER=$(kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.admin-user}' | base64 --decode)
PASS=$(kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.admin-password}' | base64 --decode)

echo "Grafana credentials:"
echo "  URL : http://localhost:3000"
echo "  User: ${USER}"
echo "  Pass: ${PASS}"
