# infrastructure : terraform + Arvan iaas

## 1. conf

`terraform.tfvars`:

- set `api_key`

## 2. init

```bash
cd infra
terraform init
```

## 3. create VMs

```bash
terraform apply
```

Wait until `vm1`, `vm2`, `vm3` are `ACTIVE`.

## 4. private IPs

```bash
terraform output nodes
```


## 5. public IPs ---> Arvan panel


## 6. add public IPs to Terraform

Edit `terraform.tfvars`:

```hcl
public_ips = {
  vm1 = "x"
  vm2 = "x"
  vm3 = "x"
}
```

Apply :

```bash
terraform apply
terraform output nodes
```

## 7. ssh

```bash
./ssh.sh vm1
./ssh.sh vm2
./ssh.sh vm3
```

## 8. install Docker 

via :

https://github.com/sinae99/Docker-install-playbook

```bash
git clone https://github.com/sinae99/Docker-install-playbook.git
cd Docker-install-playbook
# edit inventory/hosts — vm1/vm2/vm3 public IPs
ansible-playbook install-docker.yml
```


## 9. preload Kubespray images into containerd (for 403 issues)

pull images then push/load thm into containerd on the 3 VMs with:

https://github.com/sinae99/pull-save-push-load

(configured copy under `push-load/`; remote load uses `ctr -n k8s.io images import`)

```bash
cd push-load
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/SINA
ansible-playbook playbooks/push-load.yml -e "@config.yml"
```

Verify:

```bash
cd ..
./ssh.sh vm1 -- sudo crictl images
```
