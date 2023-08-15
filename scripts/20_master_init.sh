#!/bin/bash

#sudo kubeadm init --upload-certs
sudo cp /etc/kubernetes/admin.conf ~/.kube/config

# while loop for control plane pods to create or sleep or maybe we can just depend on the wait
#kubectl get pod --namespace=kube-system --selector tier=control-plane --output=jsonpath='{.items[*].metadata.name}'

# k wait loop for pods to start. this should block until they are ready.
sudo kubectl wait --namespace=kube-system --for=condition=Ready pods --selector tier=control-plane --timeout=600s

# download /etc/kubernetes/admin.conf maybe in a separate script?
sudo cp /etc/kubernetes/admin.conf /home/darrin/admin.conf
sudo chown darrin:darrin /home/darrin/admin.conf
# generate certificate key and write it to a file
cert=$(sudo kubeadm certs certificate-key)

#upload cert
sudo kubeadm init phase upload-certs --upload-certs --certificate-key $cert

# generate join command
join_cmd=$(sudo kubeadm token create --description 'cluster build' --ttl '30m' --print-join-command)

#write join command to file
echo $join_cmd | sudo tee /home/darrin/join_worker.txt
sudo chown darrin:darrin /home/darrin/join_worker.txt

# write control plane command to file
echo $join_cmd --control-plane --certificate-key $cert | sudo tee /home/darrin/join_controlplane.txt
sudo chown darrin:darrin /home/darrin/join_controlplane.txt
# or just start joining the cluster members in this script....



