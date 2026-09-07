locals {
  public_ip_for = {
    for name in var.vm_names : name => try(var.public_ips[name], null)
  }
}

output "ssh_user" {
  value = var.ssh_user
}

output "nodes" {
  value = {
    for name, vm in arvan_abrak.node : name => {
      id      = vm.id
      status  = vm.status
      private = try([for n in vm.networks : n.ip if !n.is_public && n.ip != ""][0], null)
      public  = local.public_ip_for[name]
    }
  }
}
