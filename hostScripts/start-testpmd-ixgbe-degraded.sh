#!/bin/bash

modprobe vfio
modprobe vfio_pci

for i in `lspci -D | grep X520 | awk '{print $1}'`; do
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

#count=1
#while [ "$pci_devs" != "" ]; do
	#echo "pci_devs: [$pci_devs]"
	#pci_dev_pair=`echo $pci_devs | awk '{print $1" "$2}'`
	#echo "pci_dev_pair: [$pci_dev_pair]"
	#pci_dev_pair_opt=`echo $pci_devs | awk '{print " -w "$1" -w "$2}'`
	#pci_devs=`echo $pci_devs | sed -e s/"$pci_dev_pair"//`
	#echo screen -dmS "testpmd-$count" testpmd -d /usr/lib64/librte_pmd_i40e.so -l 0,1 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_dev_pair_opt -- --portmask=3
	#((count++))
#done

#testpmd -d /usr/lib64/librte_pmd_i40e.so -l 4,5,6,7,8,9,10,11,12,13,14,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- --numa --nb-cores=6 --portmask=3F
# chrt -f 95 testpmd -d /usr/lib64/librte_pmd_ixgbe.so -l 1,5,7 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- --numa --nb-cores=2 --nb-ports=2 --portmask=3 --interactive --auto-start  
testpmd -d /usr/lib64/librte_pmd_ixgbe.so -l 1,5 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- --numa --nb-cores=1 --nb-ports=2 --portmask=3 --interactive --auto-start  


