#!/bin/bash
echo -e " \n"  
echo -e "**************************************************** \n"  
echo -e "* Restoring RHEL 7 Default Kernel Module & Services \n"  
echo -e "**************************************************** \n\n"  
tuned-adm profile network-latency 
modprobe ebtable_filter 
modprobe ebtable_broute 
modprobe ebtable_nat ebtables
modprobe ebtables
modprobe ip_tables
modprobe nf_conntrack_ipv4
modprobe nf_conntrack_ipv6
modprobe nf_conntrack
modprobe nf_nat 
modprobe ipt_REJECT
modprobe ip6t_REJECT
modprobe nf_defrag_ipv4
modprobe nf_defrag_ipv6
systemctl enable irqbalance.service
systemctl start irqbalance.service
systemctl start firewalld
systemctl enable firewalld
systemctl enable ebtables.service
systemctl start ebtables.service
echo "0" > /proc/sys/net/ipv4/ip_forward

echo -e "\n\nNow reboot system!!!\n\n"

