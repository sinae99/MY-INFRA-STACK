## My Infra Stack

my full iac platform lab configuration & automation

`compute`, `networking`

`k8s`

`observability`

`databases`, `application deployment`

`CICD`

### core phases 

1 - create VMs via Terraform

[infra/README.md](infra/README.md)

------

2 - create 3-node kubernetes cluster via Ansible

[kubernetes/README.md](kubernetes/README.md)

------

3 - implement monitoring for cluster via Prometheus

[observability/README.md](observability/README.md)

------

4 - create dashboard in Grafana

[observability/dashboards](observability/dashboards)

------

5 - deploy postgres cluster

[database/README.md](database/README.md)

------


### application

6 - api

- create a web api that get ip as input and return ip geolocation

- save outputs in postgres and use it as cache

- deploy api on kubernetes cluster

[api/README.md](api/README.md)

7 - CI/CD

[cicd/README.md](cicd/README.md)

-----------------------------------------------------------------------------------

