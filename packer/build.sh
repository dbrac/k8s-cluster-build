sudo rm -rf ./output-k8s_image
export PACKER_LOG=1
export PACKER_LOG_PATH=/tmp/packer-vmbuild.log
sudo packer build ./ubuntu_20.04.pkr.hcl
#sudo cp ./output-k8s_image/packer-k8s_image /var/lib/libvirt/images/base/packer-ubuntu.img
