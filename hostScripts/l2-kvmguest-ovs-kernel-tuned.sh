#!/bin/bash
 killall irqbalance
#tuned-adm profile network-throughput 
tuned-adm profile network-latency 
 ethtool -G em1 tx 80 rx 256
 ethtool -G em2 tx 80 rx 256
 ethtool -K em1 gro off lro off
 ethtool -K em2 gro off lro off
 ethtool -C em1 rx-usecs 25
 ethtool -C em2 rx-usecs 25
 ethtool -L em2 combined 4
 ethtool -L em1 combined 4
tuna -q em1-TxRx* -S0 -m -x
tuna -q em2-TxRx* -S0 -m -x
#7 tuna -q em1-TxRx* -S0,1 -m -x
#7 tuna -q em2-TxRx* -S0,1 -m -x
#2 echo "1" > /proc/sys/net/ipv4/ip_forward
#iptables -D INPUT 7
#iptables -D FORWARD 9
#3 arp -s 10.0.0.1 ec:f4:bb:ce:cf:78
#1 sysctl -w net.ipv4.ip_early_demux=0
#1 sysctl -w net.ipv4.conf.default.rp_filter=0
#1 sysctl -w net.ipv4.conf.default.accept_local=1
#1 sysctl -w net.ipv4.conf.default.send_redirects=0
#1 sysctl -w net.ipv4.conf.all.rp_filter=0
#1 sysctl -w net.ipv4.conf.all.accept_local=1
#1 sysctl -w net.ipv4.conf.all.send_redirects=0
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
#4 ethtool -K em1 ntuple on
#4 ethtool -K em2 ntuple on
#4 for i in `seq 0 23`
#4 do
#4        ethtool -N em1 flow-type ip4 src-ip 192.168.0.`expr 10 + $i` action $i
#4        ethtool -N em2 flow-type ip4 src-ip 192.168.0.`expr 10 + $i` action $i
#4 done

rmmod ebtable_filter ebtables
