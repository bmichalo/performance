#!/bin/bash

modprobe vfio
modprobe vfio_pci

for i in `lspci -D | grep -E X520\|XL710 | awk '{print $1}'`; do
	pci_devs="$pci_devs $i"
	pci_devs_opt="$pci_devs_opt -w $i"
done

for pci_dev in $pci_devs; do

	if [ -e /sys/bus/pci/devices/"$pci_dev"/net ]; then
		net_dev=`/bin/ls /sys/bus/pci/devices/"$pci_dev"/net`
		ifconfig $net_dev down
		dpdk_nic_bind.py -u $pci_dev
	fi
	dpdk_nic_bind.py -b vfio-pci $pci_dev

done

testpmd -d /usr/lib64/librte_pmd_i40e.so -d /usr/lib64/librte_pmd_ixgbe.so -l 1,4,6,8,10,12,14,5,7,9,11,13,15,17,19 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- --numa --nb-cores=14 --nb-ports=14 --portmask=3FFF --interactive --auto-start  



