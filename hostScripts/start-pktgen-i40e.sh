#!/bin/bash

modprobe vfio
modprobe vfio_pci

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

# pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,5,6,7,8,9,10,11,12,13,14,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "5.0, 7.1, 9.2, 11.3, 13.4, 15.5, 4.6, 6.7, 8.8, 10.9, 12.10, 14.11" -l ptkgen.log

# echo  pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,5,6,7,8,9,10,11,12,13,14,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "5.0, 7.1, 9.2, 11.3, 13.4, 15.5, 4.6, 6.7, 8.8, 10.9, 12.10, 14.11" -l ptkgen.log

# pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,6,8,10,12,14,5,7,9,11,13,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "[4].0, [6].1, [8].2, [10].3, [12].4, [14].5, [5].6, [7].7, [9].8, [11].9, [13].10, [15].11" -l ptkgen.log -f pktgen.pkt
pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,6,8,10,12,14,5,7,9,11,13,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "[4].0, [6].1, [8].2, [10].3, [12].4, [14].5, [5].6, [7].7, [9].8, [11].9, [13].10, [15].11" -l ptkgen.log 

