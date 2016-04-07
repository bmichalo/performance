#!/bin/bash

log_dir=/tmp
nr_vms=$1

vms=""
for i in `seq 1 $nr_vms`; do
	vms="vm$i $vms"
done

for vm in $vms; do
	vm_hostname=`grep "login:" "$log_dir/$vm.console" | awk '{print $1}'`
	if ping -c 1 $vm_hostname 2>&1 >/dev/null; then 
		printf "%20s%20s\n" $vm $vm_hostname
	else
		printf "%20s%20s FAILED\n" $vm $vm_hostname
	fi
done
