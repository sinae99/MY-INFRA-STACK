#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

list_hosts() {
  terraform output -json nodes | python3 -c '
import json, sys
for name, n in sorted(json.load(sys.stdin).items()):
    print(f"  {name}  public={n.get(\"public\") or \"-\"}  private={n.get(\"private\") or \"-\"}")
'
}

usage() {
  echo "Usage: $0 <vm-name> [ssh options...]"
  echo
  echo "Hosts:"
  list_hosts
  exit 1
}

[[ $# -ge 1 ]] || usage

HOST="$1"
shift

IP="$(terraform output -json nodes | python3 -c "
import json, sys
host = sys.argv[1]
n = json.load(sys.stdin)[host]
ip = n.get('public') or n.get('private')
if not ip:
    raise SystemExit(f'no ip for {host}')
print(ip)
" "$HOST")"

USER="$(terraform output -raw ssh_user)"

echo "ssh ${USER}@${IP}"
exec ssh -o StrictHostKeyChecking=accept-new "${USER}@${IP}" "$@"
