#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

# Prefer ~/.ssh/SINA when present (this project's key name).
if [[ -n "${SSH_PRIVATE_KEY:-}" ]]; then
  SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY/#\~/$HOME}"
elif [[ -f "${HOME}/.ssh/SINA" ]]; then
  SSH_PRIVATE_KEY="${HOME}/.ssh/SINA"
else
  SSH_PRIVATE_KEY="${HOME}/.ssh/id_rsa"
fi

KUBESPRAY_IMAGE="${KUBESPRAY_IMAGE:-quay.io/kubespray/kubespray:v2.28.1}"
INVENTORY="${ROOT}/inventory/mycluster/hosts.yaml"

if [[ ! -f "${INVENTORY}" ]]; then
  echo "error: ${INVENTORY} not found; run ./generate-inventory.sh first" >&2
  exit 1
fi

mkdir -p "${ROOT}/kubespray_cache"
mkdir -p "${HOME}/.ssh"
touch "${HOME}/.ssh/known_hosts"

DOCKER_ARGS=(
  --rm -it
  -v "${ROOT}/inventory:/kubespray/inventory"
  -v "${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts"
  -v "${ROOT}/kubespray_cache:/tmp/kubespray_cache"
  -e "ANSIBLE_CONFIG=/kubespray/ansible.cfg"
)

ANSIBLE_EXTRA=(
  -e host_key_checking=False
)

# Prefer ssh-agent for passphrase-protected keys.
# Load once on the host: ssh-add ~/.ssh/SINA
if [[ -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
  echo "Using ssh-agent (${SSH_AUTH_SOCK})"
  DOCKER_ARGS+=(
    -v "${SSH_AUTH_SOCK}:/ssh-agent"
    -e "SSH_AUTH_SOCK=/ssh-agent"
  )
else
  if [[ ! -f "${SSH_PRIVATE_KEY}" ]]; then
    echo "error: SSH private key not found at ${SSH_PRIVATE_KEY}" >&2
    echo "Set SSH_PRIVATE_KEY, or load a passphrase key into the agent:" >&2
    echo "  eval \"\$(ssh-agent -s)\"" >&2
    echo "  ssh-add ~/.ssh/SINA" >&2
    echo "  ./kubespray.sh" >&2
    exit 1
  fi
  echo "WARNING: no ssh-agent detected; mounting ${SSH_PRIVATE_KEY}" >&2
  echo "If this key has a passphrase, Ansible forks may fail. Prefer:" >&2
  echo "  eval \"\$(ssh-agent -s)\"" >&2
  echo "  ssh-add ${SSH_PRIVATE_KEY}" >&2
  echo "  ./kubespray.sh" >&2
  DOCKER_ARGS+=(
    -v "${SSH_PRIVATE_KEY}:/root/.ssh/id_rsa:ro"
  )
  ANSIBLE_EXTRA+=(
    -e ansible_ssh_private_key_file=/root/.ssh/id_rsa
  )
fi

if [[ $# -eq 0 ]]; then
  set -- ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml --become
fi

docker run "${DOCKER_ARGS[@]}" \
  "${KUBESPRAY_IMAGE}" \
  "$@" \
  "${ANSIBLE_EXTRA[@]}"
