#!/usr/bin/env bash
set -euo pipefail

echo "Stopping port-forwards..."

for name in prometheus grafana alertmanager; do
  pidfile="/tmp/pf-${name}.pid"
  if [[ -f "${pidfile}" ]]; then
    kill "$(cat "${pidfile}")" 2>/dev/null || true
    rm -f "${pidfile}"
  fi
done

echo "Stopped."
