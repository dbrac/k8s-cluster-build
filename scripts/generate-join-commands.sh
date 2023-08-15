# get join command
kubeadm token create --description 'cluster build script' --ttl '30m' --print-join-command
# kubeadm join 10.1.3.4:6443 --token y4s5ko.mos3zuc55gz8utmt --discovery-token-ca-cert-hash sha256:8e334b3653dd43ac19f3d2892ba76bae058101f1ff38fac56666f0308665bd94

# verify it was created
kubeadm token list

# get cert for joining additional masters. This allows certificates to be copied automatiaclly.
kubeadm certs certificate-key
ccf77f376f401c9627792417a61e919b0a755a53625a7537f0bfc8a0e116416d