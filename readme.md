# Description
The purpose of t his project is to automate the kubernetes cluster build and providing a way to quickly test Kubernetes solutions. 
The play book handles creation of Ubuntu images, Virtual Machines on KVM, and the Kubernetes cluster.

Reference [all.yml](inv%2Fgroup_vars%2Fall.yml) for versions currently in use or to change versions.

### Kubernetes

This playbook will build a single node control plane with three worker nodes. It uses Calico CNI, Nginx ingress controller
and containerd runtime.

#### Ubuntu
This playbook simply pulls the latest Ubuntu cloud image (currently 22.04) and uses it in its default form. It is sometimes useful to
modify the image rather than modify a server deployed from it. See the packer directory for an example of how to do this which
is there for reference but otherwise not currently used.

#### KVM

This playbook builds VM's on KVM which are then used to become cluster nodes. This works well because any platform
where you can deploy an ubuntu server can be used to host this cluster.

# Usage
1. Update [all.yml](inv%2Fgroup_vars%2Fall.yml) with your ssh key and any version changes you may need to make.
2. Update [hosts.yaml](inv%2Fhosts.yaml) with the IP address of your KVM server and IP addresses you will use for your cluster nodes.
3. Configure KVM prerequisites:
   - you have root access
   - Resources: 100GB disk, 12GB RAM and 2 CPU's
   - CPU extensions are enabled (Intel VT or AMD-V)
   - you have a bridge (br0) properly configured. Below is an example of how you can define your netplan network config
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
4. Run the following plays to setup the KVM server:
   - plays/kvm_host_setup.yaml -i inv/hosts.yaml
   - plays/kvm_download_cloud_image.yaml -i inv/hosts.yaml


5. Build the Kubernetes cluster
   - build_k8s_cluster.yaml