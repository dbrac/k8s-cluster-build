# Packer Example
To keep it simple, I didn't use a custom image for the cluster build playbook. This is just a reference because you would
most likely need a custom image for a production environment.

Packer docs: https://developer.hashicorp.com/packer/docs?ajs_aid=62797e0b-a6fc-48bb-ad64-153a5abf7bfa&product_intent=packer

Packer can build images for many platforms and this example uses the QEMU builder to build a virtual machine image for KVM.
It works by creating a VM on the KVM server, executing the scripts within the packer file and then saving a copy of the 
virtual disk. The virtual disk is a QCOW2 file and uses a copy on write format meaning it's only as big as it needs to 
be. It can also be used as a parent image with children VM's linked to it so that the children are also only as big 
as they need to be.

### Building a Custom Image

Review the packer file [ubuntu_20.04.pkr.hcl](ubuntu_20.04.pkr.hcl). This is where you can add your own customizations.

Run the following play which requires that you have already set up a KVM  server and updated the inv/hosts.yaml file 
with its IP address.

    - plays/kvm_build_custom_image.yaml -i inv/hosts.yaml

The play will have a long period with no output while the VM is being built. Logon to the KVM server and tail the 
/tmp/packer-vmbuild.log file to monitor the progress and troubleshoot the build.

# Documentation
Packer: https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu