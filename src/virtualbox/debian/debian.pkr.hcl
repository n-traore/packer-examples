# Create image for a Virtualbox VM that includes Spark and Cassandra

source "virtualbox-iso" "vm" {
  boot_command = [
    "<esc><wait>",
    "auto <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg <wait>",
    "<enter>"
  ]
  boot_wait            = "10s"
  cpus                 = "1"
  disk_size            = "20000"
  format               = "ovf"
  guest_additions_mode = "upload"
  guest_os_type        = "Debian_64"
  headless             = "false"
  http_directory       = "http"
  iso_checksum         = "sha256:9f181ae12b25840a508786b1756c6352a0e58484998669288c4eec2ab16b8559"
  iso_target_path      = "iso/debian-12.1.0-amd64-netinst.iso"
  iso_url              = "https://cdimage.debian.org/mirror/cdimage/archive/12.1.0/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso"
  memory               = "1024"
  output_directory     = "built-images/${var.vm_name}"
  shutdown_command     = "echo ${var.ssh_pass} | sudo -S shutdown -P now"
  skip_nat_mapping     = true
  ssh_password         = "${var.ssh_pass}"
  ssh_port             = var.ssh_port
  ssh_timeout          = "30m"
  ssh_username         = "${var.ssh_user}"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--nat-pf1", "packerssh,tcp,,${var.ssh_port},,22"],
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"]
  ]
  vm_name = "${var.vm_name}"
}

build {
  sources = ["source.virtualbox-iso.vm"]

  provisioner "shell" {
    environment_vars = [
      "SU_USR=${var.ssh_user}"
    ]
    execute_command = "echo ${var.ssh_pass} | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    scripts          = ["scripts/virtualbox/install-guest-adds.sh", "scripts/install-spark.sh", "scripts/install-cassandra.sh"]
  }

  post-processor "compress" {
    keep_input_artifact = true
    output = "built-images/compressed/${var.vm_name}.tar.gz"
  }
}
