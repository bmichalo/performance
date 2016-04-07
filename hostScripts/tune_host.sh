#!/bin/bash
killall irqbalance
tuned-adm profile network-latency 
ethtool -L em1 combined 2
ethtool -L em2 combined 2

tuna -q em1-TxRx* --cpus=2,4 -m -x
tuna -q em2-TxRx* --cpus=6,8 -m -x
#tuna -q em1-TxRx* -S0 -m -x
#tuna -q em2-TxRx* -S0 -m -x
#tuna -q em1-TxRx* -S0,1 -m -x
#tuna -q em2-TxRx* -S0,1 -m -x
iptables -D INPUT 7
iptables -D FORWARD 9
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

