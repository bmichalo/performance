#!/bin/bash

modprobe uio_pci_generic
#modprobe vfio_pci

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


pktgen -d /usr/lib64/librte_pmd_i40e.so -l 0,1,2 --socket-mem 1024,0 -n 4 --proc-type auto --file-prefix pg -w 0000:00:08.0 -w 0000:00:09.0 -- -N -T -P -m "1.0, 2.1" -l ptkgen.log
# pktgen -d /usr/lib64/librte_pmd_i40e.so -l 0,1 --socket-mem 1024,0 -n 4 --proc-type auto --file-prefix pg -w 0000:00:07.0 -- -N -T -P -m "1.0" -l ptkgen.log
# pktgen -d /usr/lib64/librte_pmd_i40e.so -l 0,1,2,3 --socket-mem 1024,0 -n 4 --proc-type auto --file-prefix pg -w 0000:00:06.0 -w 0000:00:07.0 -w 0000:00:08.0 -w 0000:00:09.0 -w 0000:00:0a.0 -w 0000:00:0b.0 -- -N -T -P -m "1.[0-1], 2.[2-3], 3.[4-5]." -l ptkgen.log
