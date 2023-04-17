variable "iso_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://cloud-images.ubuntu.com/releases/focal/release/SHA256SUMS"
}

source "qemu" "ubuntu_image" {
  iso_url           = "${var.iso_url}"
  iso_checksum      = "${var.iso_checksum}"
  disk_size         = "5000M"
  disk_image        = true
  disk_discard      = "unmap"
  http_directory    = "data"
  memory            = "4096"
  cpus              = "2"
  format            = "qcow2"
  accelerator       = "kvm"
  ssh_username      = "packer"
  ssh_password      = "thisok"
  ssh_timeout       = "20m"
  disk_interface    = "virtio-scsi"
  qemuargs          = [["-smbios", "type=1,serial=ds=nocloud-net;instance-id=packer;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/cloud-data/"]]
  use_default_display = true
}

build {
  sources = ["source.qemu.ubuntu_image"]

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/cloud",
      "sudo mkdir /etc/packerdir",
    ]
    remote_folder="/tmp"
  }
}
