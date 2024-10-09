variable "vm_name" {
  type    = string
  default = "spark-vm"
}

variable "domain" {
  type    = string
  default = "local"
}

variable "ssh_pass" {
  type    = string
  default = "spark"
}

variable "ssh_user" {
  type    = string
  default = "spark"
}

variable "ssh_port" {
  type    = number
  default = 2222
}