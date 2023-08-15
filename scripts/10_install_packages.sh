#!/bin/bash
# ssh darrin@server 'bash -s' < script.sh
VERSION=1.26.3-00
RUNC=1.1.0
CONTAINERD=1.6.2

# load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# add kuberentes apt key and repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo deb https://apt.kubernetes.io/ kubernetes-xenial main | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
#sudo bash -c 'cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
#deb https://apt.kubernetes.io/ kubernetes-xenial main
#EOF'

# install k8s packages
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -y --quiet=2 kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl
# you can apt-get install containerd which will install runc as a dependency. These are distributed by Docker and not the
# by the actual projects. They also are older versions. The latest versions you can download direcly like this:
# sudo apt-get install containerd


# how to install containerd and runc
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md

# install containerd
# curl must have -L for this call to follow redirect or else this won't work
#sudo curl -fsSL --output /tmp/containerd-1.6.2-linux-amd64.tar.gz  https://github.com/containerd/containerd/releases/download/v1.6.20/containerd-1.6.20-linux-amd64.tar.gz
sudo curl -fsSL --output /tmp/containerd-1.6.2-linux-amd64.tar.gz  https://github.com/containerd/containerd/releases/download/v${CONTAINERD}/containerd-${CONTAINERD}-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local /tmp/containerd-${CONTAINERD}-linux-amd64.tar.gz
sudo rm -f /tmp/containerd-${CONTAINERD}-linux-amd64.tar.gz
sudo curl -fsSL --output /lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# install runc
sudo curl -fsSL --output /usr/sbin/runc https://github.com/opencontainers/runc/releases/download/v${RUNC}/runc.amd64
sudo chmod 750 /usr/sbin/runc

# start containerd
sudo systemctl daemon-reload
sudo systemctl enable --now containerd