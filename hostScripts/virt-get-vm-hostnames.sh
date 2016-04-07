#!/bin/bash

# This script will map vm-name to their hostnames
# Please see the requirements in boot-vms in order
# for thisscript to work
	

log_dir=/tmp

vms=`virsh list | grep running |awk '{print $2}'`
# echo vms: $vms
#printf "%20s%20s#\n" "vm-name" "hostname"
for vm in $vms; do
	if grep -q "login:" "$log_dir/$vm.console"; then
		vm_hostname=`grep "login:" "$log_dir/$vm.console" | tail -1 | awk '{print $1}'`
		printf "%-8s%-20s\n" $vm $vm_hostname
	fi
done
