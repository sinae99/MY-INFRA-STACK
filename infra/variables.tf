variable "api_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type = string
}

variable "distro_name" {
  type = string
}

variable "distro_version" {
  type = string
}

variable "plan_id" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "ssh_key_name" {
  type     = string
  default  = null
  nullable = true
}

variable "ssh_user" {
  type = string
}

variable "network_name" {
  type = string
}

variable "network_cidr" {
  type = string
}

variable "network_gateway" {
  type = string
}

variable "dhcp_start" {
  type = string
}

variable "dhcp_end" {
  type = string
}

variable "vm_names" {
  type = list(string)
}

variable "public_ips" {
  type        = map(string)
  description = "Public IP per VM name"
  default     = {}
}
