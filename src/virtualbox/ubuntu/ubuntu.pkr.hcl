# Create image for a Virtualbox VM that includes Spark and Cassandra

source "virtualbox-iso" "vm" {
  boot_command = [
        "<esc><esc><enter><wait>",
        "/install/vmlinuz noapic ",
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
        "debian-installer=fr_FR auto locale=fr_FR kbd-chooser/method=fr<wait>",
        " console-setup/ask_detect=false<wait>",
        " fb=false debconf/frontend=noninteractive <wait>",
        " keyboard-configuration/layout=FR<wait>",
        " keyboard-configuration/variant=FR<wait>",
        " locale=fr_FR<wait>",
        #" netcfg/get_domain=${var.domain}<wait>",
        " netcfg/get_hostname=${var.vm_name}<wait>",
        " initrd=/install/initrd.gz -- <enter>"
  ]
  boot_wait            = "10s"
  cpus                 = "1"
  disk_size            = "20000"
  format               = "ovf"
  guest_additions_mode = "upload"
  guest_os_type        = "Ubuntu_64"
  headless             = "false"
  http_directory       = "http/ubuntu"
  iso_checksum         = "sha256:f5cbb8104348f0097a8e513b10173a07dbc6684595e331cb06f93f385d0aecf6"
  iso_target_path      = "iso/ubuntu-18.04.6-server-amd64.iso"
  iso_url              = "https://cdimage.ubuntu.com/ubuntu/releases/18.04.6/release/ubuntu-18.04.6-server-amd64.iso"
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
    output = "built-images/compressed/${var.vm_name}.tar.xz"
  }
}
