#!/bin/bash
# ssh darrin@server 'bash -s' < script.sh
VERSION=1.26.3-00

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'
#sudo apt-get update
# you can apt-get install containerd which will install runc as a dependency. These are distributed by Docker and not the
# by the actual projects. They also are older versions. The latest versions you can download direcly like this:
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION

# must have -L to follow redirect or this won't work
curl -fsSL --output ./containerd.tar.gz  https://github.com/containerd/containerd/releases/download/v1.6.20/containerd-1.6.20-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz
#download the unit file
curl -fsSL --output ./containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv ./containerd.service /usr/local/lib/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

#sudo apt-mark hold kubelet kubeadm kubectl
