variable "iso_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://cloud-images.ubuntu.com/releases/jammy/release/SHA256SUMS"
}

variable "k8s_version" {
    type    = string
    default = "1.26.13-1.1"
}

variable "containerd_version" {
    type    = string
    default = "1.6.2"
}

variable "runc_version" {
    type    = string
    default = "1.1.0"
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
      "sudo curl -fsSL --output /tmp/containerd.tar.gz https://github.com/containerd/containerd/releases/download/v${var.containerd_version}/containerd-${var.containerd_version}-linux-amd64.tar.gz",
      "sudo tar -zxvf /tmp/containerd.tar.gz -C /usr/",
      "sudo rm -f /tmp/containerd.tar.gz",
      "echo extracted containerd",
      "sudo curl -fsSL --output /lib/systemd/system/containerd.service http://$${PACKER_HTTP_ADDR}/containerd/containerd.service",
      "echo downloaded containerd service",
      "sudo curl -fsSL --output /etc/modules-load.d/containerd.conf http://$${PACKER_HTTP_ADDR}/containerd/containerd.conf",
      "echo downloaded conf",
      "sudo curl -fsSL --output /usr/sbin/runc https://github.com/opencontainers/runc/releases/download/v${var.runc_version}/runc.amd64",
      "echo downloaded runc",
      "sudo mkdir -p /etc/apt/keyrings/",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "sudo /usr/bin/apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -y --quiet=2 install kubelet=${var.k8s_version} kubeadm=${var.k8s_version} kubectl=${var.k8s_version}",
      "sudo apt-mark hold kubelet kubeadm kubectl"
    ]
    remote_folder="/tmp"
  }
}
