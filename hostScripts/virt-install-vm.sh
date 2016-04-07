#!/bin/bash

vm=master
bridge=virbr0
master_image=master.qcow2
image_path=/var/lib/libvirt/images/
dist=f22
#location="http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os/"
location="http://download.eng.bos.redhat.com/released/F-22/GOLD/Server/x86_64/os/"
extra="ks=file:/$dist-vm.ks console=ttyS0,115200"
#location="http://download.eng.bos.redhat.com/released/F-21/GOLD/Server/x86_64/os/"

/root/shutdown-all-vms
/root/destroy-all-vms
echo deleting master image
/bin/rm -f $image_path/$master_image

echo creating new master image
qemu-img create -f qcow2 $image_path/$master_image 100G
echo undefining master xml
virsh list --all | grep master && virsh undefine master
echo calling virt-install
virt-install --name=$vm\
	 --virt-type=kvm\
	 --disk path=$image_path/$master_image,format=qcow2\
	 --vcpus=4\
	 --ram=2048\
	 --network bridge=$bridge\
	 --os-type=linux\
	 --os-variant=rhel7\
	 --graphics none\
	 --extra-args="$extra"\
	 --initrd-inject=/root/$dist-vm.ks\
	 --serial pty\
	 --serial file,path=/tmp/$vm.console\
	 --location=$location\
	 --noreboot
