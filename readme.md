# Description
The purpose of this project is to automate the kubernetes cluster build providing a way to quickly test Kubernetes solutions. 
The play book handles creation of Ubuntu images, Virtual Machines on KVM, and the Kubernetes cluster.

Reference [all.yml](inv%2Fgroup_vars%2Fall.yml) to see which versions are used.

This playbook will build a single node control plane with three worker nodes. It uses Calico CNI, Nginx ingress controller
and containerd runtime. Optionally, there is a play to pull the latest Ubuntu cloud image (currently 22.04) which can then
be used to create the VM's. It is sometimes useful to use a custom image instead. See the packer [readme.md](packer%2Freadme.md) 
for an example of how to do this. Optionally, there are plays to build the VM's on KVM which are then used to become 
cluster nodes. This works well because any platform where you can deploy an ubuntu server can be used to host this cluster.


# Usage
1. Update [all.yml](inv%2Fgroup_vars%2Fall.yml) with your ssh key, username, password and any version changes you may need to make.
   2. If you do not want to allow password logon, modify the cloud init file accordingly [user-data.yml.j2](files%2Fuser-data.yml.j2).
   Reference cloud init docs https://cloudinit.readthedocs.io/en/latest/reference/index.html
   

2. Update [hosts.yaml](inv%2Fhosts.yaml) with the IP address allocated for your KVM server and K8S cluster nodes.


3. KVM server prerequisites:
   - you have root access
   - Resources: 50GB disk, 12GB RAM and 4 CPU's (resources for four VM's)
   - CPU extensions are enabled (Intel-VT or AMD-V). This is platform specific but required by QEMU.
   - A properly configured bridge (br0). Below is an example of how you can define your netplan network config to
     accomplish this.
    ```
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: false
          dhcp6: false
      bridges:
        br0:
          interfaces:
            - eth0
          addresses:
            - 192.168.1.201/24
          gateway4: 192.168.1.1
          nameservers:
            addresses: [8.8.8.8, 8.8.4.4]
    ```
4. Run the following play to set up the KVM server:
   - plays/kvm_host_setup.yaml -i inv/hosts.yaml


5. If you didn't setup the KVM server describe above and are handling your own VM creation, then you need to commend the 
following plays in [build_k8s_cluster.yaml](build_k8s_cluster.yaml)
   -  [00_kvm_destroy_vm.yaml](plays%2F00_kvm_destroy_vm.yaml)
   - [10_kvm_create_vm.yaml](plays%2F10_kvm_create_vm.yaml)
   - [20_wait_for_vms_to_start.yaml](plays%2F20_wait_for_vms_to_start.yaml)


5. Run this play to build Kubernetes cluster. 
   - build_k8s_cluster.yaml -i inv/hosts.yaml


6. The last play in the cluster build installs kubectl and admin.conf onto your localhost. Upon completion, you should
be ready to start interacting with the cluster. Try the following commands to verify.
   - kubectl version
   - kubectl get nodes
   - kubectl get pods -A

8. Optional. If you want to use ingresses for your own applications then you need to set up name resolution to get your http traffic to nginx. The nginx service is configured as a nodeport service with "externalTrafficPolicy" set to "Cluster". This means you just need to get your http traffic (ports 80/443) to any cluster node where kube-proxy will forward it to nginx which will then forward to your backend service. A simple way to do that is to update your local hosts file to resolve the hosts specified in your ingress spec. For example:

    Add this to your hosts file:
    192.168.1.202 shortener.dblab.com

    For an ingress that looks something like this:
    ```
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    name: url-shortener-ingress
    spec:
    ingressClassName: nginx
    rules:
      - host: shortener.dblab.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: url-shortener-svc
                port:
                  number: 80
    ```

# Documentation links
Cloud init:
https://cloudinit.readthedocs.io/en/latest/reference/index.html

Ansible:
https://docs.ansible.com/ansible/latest/index.html

Ubuntu Cloud Images:
https://cloud-images.ubuntu.com/

Packer:
https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu

KVM:
https://www.linux-kvm.org/page/Documents

# TODO
- Multi node control plane for HA
- HA proxy to load balance multi node control plane
- Typha for calico
