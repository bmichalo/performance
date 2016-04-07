#!/bin/bash

modprobe uio_pci_generic

for i in `lspci -D | grep XL710 | awk '{print $1}'`; do
	pci_devs="$pci_devs $i"
	pci_devs_opt="$pci_devs_opt -w $i"
done

for pci_dev in $pci_devs; do

	if [ -e /sys/bus/pci/devices/"$pci_dev"/net ]; then
		net_dev=`/bin/ls /sys/bus/pci/devices/"$pci_dev"/net`
		ifconfig $net_dev down
		dpdk_nic_bind.py -u $pci_dev
	fi
	dpdk_nic_bind.py -b uio_pci_generic $pci_dev

done

~/dpdk/build/app/testpmd -d /usr/lib64/librte_pmd_i40e.so -l 0,1,2 --socket-mem 1024,0 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- --nb-cores=2 --nb-ports=2 --portmask=3 --interactive --auto-start 
