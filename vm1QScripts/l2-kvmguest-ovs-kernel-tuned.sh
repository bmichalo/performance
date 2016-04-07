#!/bin/bash
killall irqbalance
#tuned-adm profile network-latency 
#ethtool -K eth1 gro off lro off
#ethtool -K eth2 gro off lro off
#ethtool -L eth1 combined 4
#ethtool -L eth2 combined 4
#tuna -q virtio3-input* -c 0-3 -m -x
#tuna -q virtio4-input* -c 0-3 -m -x
#tuna -q virtio3-output* -c 0-3 -m -x
#tuna -q virtio4-output* -c 0-3 -m -x
systemctl stop firewalld
systemctl disable firewalld
iptables -F ; iptables -t nat -F; iptables -t mangle -F ; ip6tables -F
iptables -X ; iptables -t nat -X; iptables -t mangle -X ; ip6tables -X
iptables -t raw -F ; iptables -t raw -X
modprobe -r ebtable_broute ebtable_nat ebtable_filter ebtables
modprobe -r ipt_SYNPROXY 
modprobe -r nf_synproxy_core 
modprobe -r xt_CT
modprobe -r nf_conntrack_ftp
modprobe -r nf_conntrack_tftp 
modprobe -r nf_conntrack_irc 
modprobe -r nf_nat_tftp ipt_MASQUERADE 
modprobe -r iptable_nat
modprobe -r nf_nat_ipv4 
modprobe -r nf_nat 
modprobe -r nf_conntrack_ipv4 
modprobe -r nf_nat 
modprobe -r nf_conntrack_ipv6 
modprobe -r xt_state
modprobe -r xt_conntrack iptable_raw 
modprobe -r nf_conntrack 
modprobe -r iptable_filter 
modprobe -r iptable_raw
modprobe -r iptable_mangle
modprobe -r ipt_REJECT xt_CHECKSUM 
modprobe -r ip_tables 
modprobe -r nf_defrag_ipv4
modprobe -r ip6table_filter 
modprobe -r ip6_tables 
modprobe -r nf_defrag_ipv6 
modprobe -r ip6t_REJECT 
modprobe -r xt_LOG 
modprobe -r xt_multiport
modprobe -r nf_conntrack
rmmod ebtable_filter ebtables
