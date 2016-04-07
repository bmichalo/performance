#!/bin/bash

dist=rhel72
vm=vm2
bridge=virbr0
vm2_image=vm2.raw
ks=$dist-vm.ks
image_path=/var/lib/libvirt/images/
nr_vms=0

case $dist in
    rhel71)
	#location="http://download.devel.redhat.com/released/RHEL-7/7.1/Server/x86_64/"
	location="http://download.devel.redhat.com/released/RHEL-7/7.1-RC-2/Server/x86_64/os//"
	;;
    rhel72)
	location="http://download.devel.redhat.com/released/RHEL-7/7.2/Server/x86_64/os/"
	;;
    f22)
	location="http://download.devel.redhat.com/released/F-22/GOLD/Server/x86_64/os/"
	;;
esac

#location="http://download.eng.rdu2.redhat.com/nightly/RHEL-7.2-20150427.n.1/compose/Server/x86_64/os/"
extra="ks=file:/$ks console=ttyS0,115200"

echo deleting vm2 image
/bin/rm -f $image_path/$vm2_image

echo deleting vm image copies
for i in `seq 1 $nr_vms`; do
	set -x
	/bin/rm -f $image_path/vm*.qcow2
	set +x
done

echo creating new vm2 image
qemu-img create -f raw $image_path/$vm2_image 100G

echo undefining vm2 xml
virsh list --all | grep vm2 && virsh undefine vm2

echo calling virt-install

# normal
virt-install --name=$vm \
	 --virt-type=kvm \
	 --disk path=$image_path/$vm2_image,format=raw \
         --vcpus=4,cpuset=12,14,16,18 \
	 --ram=4096 \
	 --network bridge=$bridge \
	 --os-type=linux \
	 --os-variant=rhel7 \
	 --graphics none \
	 --extra-args="$extra" \
	 --initrd-inject=/root/$ks \
	 --serial pty \
	 --serial file,path=/tmp/$vm.console \
	 --location=$location \
	 --noreboot

# realtime
#virt-install --name=$vm \
    #--virt-type=kvm \
    #--disk path=$image_path/$vm2_image,format=raw,bus=virtio,cache=none,io=threads \
    #--vcpus=2,cpuset=14,15 \
    #--numatune=1 \
    #--memory=1024,hugepages=yes \
    #--memorybacking hugepages=yes,size=1,unit=G,locked=yes,nodeset=1 \
    #--network bridge=$bridge \
    #--os-type=linux \
    #--os-variant=rhel7 \
    #--graphics none \
    #--extra-args="$extra" \
    #--initrd-inject=/root/$ks \
    #--serial pty \
    #--serial file,path=/tmp/$vm.console \
    #--location=$location \
    #--noreboot
