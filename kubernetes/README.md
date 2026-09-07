# kubernetes cluster : Kubespray

install 3-node cluster on the Arvan VMs created by [infra/](../infra/README.md):

| Node | Role |
|------|------|
| vm1 | control-plane + etcd |
| vm2 | worker |
| vm3 | worker |

Stack: 
**Kubespray v2.28.1**, **Calico** CNI, **containerd** CRI..


## 1. generate inventory from Terraform

```bash
cd kubernetes
./generate-inventory.sh
```

## 2. install the cluster

```bash
./kubespray.sh
```

## 3. fetch kubeconfig

```bash
./fetch-kubeconfig.sh
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl get nodes
```

Expected:

```
NAME   STATUS   ROLES           AGE   VERSION
vm1    Ready    control-plane   ...   v1.30.x
vm2    Ready    <none>          ...   v1.30.x
vm3    Ready    <none>          ...   v1.30.x
```


## files

| File | Purpose |
|------|---------|
| `generate-inventory.sh` | Build Ansible inventory from `../infra` Terraform output |
| `kubespray.sh` | Run Kubespray playbooks via Docker |
| `fetch-kubeconfig.sh` | Copy `admin.conf` from vm1 and fix the API server URL |
| `inventory/mycluster/hosts.yaml` | Generated node list and roles |
| `inventory/mycluster/group_vars/` | Cluster tuning (Calico, cert SANs) |


