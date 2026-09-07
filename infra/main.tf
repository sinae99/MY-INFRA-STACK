terraform {
  required_version = ">= 1.0"

  required_providers {
    arvan = {
      source  = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

provider "arvan" {
  api_key = var.api_key
}

data "arvan_security_groups" "default" {
  region = var.region
}

data "arvan_images" "distributions" {
  region     = var.region
  image_type = "distributions"
}

data "arvan_plans" "plans" {
  region = var.region
}

locals {
  chosen_image = one([
    for image in data.arvan_images.distributions.distributions : image
    if image.distro_name == var.distro_name && image.name == var.distro_version
  ])

  selected_plan = one([
    for plan in data.arvan_plans.plans.plans : plan
    if plan.id == var.plan_id
  ])
}

resource "arvan_network" "cluster" {
  region      = var.region
  description = "private network"
  name        = var.network_name

  dhcp_range = {
    start = var.dhcp_start
    end   = var.dhcp_end
  }

  dns_servers    = ["8.8.8.8", "1.1.1.1","178.22.122.100","185.51.200.2"]
  enable_dhcp    = true
  enable_gateway = true
  cidr           = var.network_cidr
  gateway_ip     = var.network_gateway
}

resource "arvan_abrak" "node" {
  for_each = toset(var.vm_names)

  depends_on = [arvan_network.cluster]

  timeouts {
    create = "45m"
    update = "45m"
    delete = "20m"
    read   = "10m"
  }

  region       = var.region
  name         = each.key
  image_id     = local.chosen_image.id
  flavor_id    = local.selected_plan.id
  disk_size    = var.disk_size
  enable_ipv4  = true
  ssh_key_name = var.ssh_key_name

  networks = [
    {
      network_id = arvan_network.cluster.network_id
    }
  ]

  security_groups = [data.arvan_security_groups.default.groups[0].id]
}
