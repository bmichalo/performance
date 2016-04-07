#!/bin/bash
#7 killall irqbalance
#tuned-adm profile network-throughput 
tuned-adm profile network-latency 
#1 ethtool -G em1 tx 80 rx 256
#1 ethtool -G em2 tx 80 rx 256
#1 ethtool -K em1 gro off lro off
#1 ethtool -K em2 gro off lro off
#1 ethtool -C em1 rx-usecs 25
#1 ethtool -C em2 rx-usecs 25
#7 ethtool -L em2 combined 12
#7 ethtool -L em1 combined 12
#tuna -q em1-TxRx* -S0 -m -x
#tuna -q em2-TxRx* -S0 -m -x
#7 tuna -q em1-TxRx* -S0,1 -m -x
#7 tuna -q em2-TxRx* -S0,1 -m -x
#2 echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -D INPUT 7
iptables -D FORWARD 9
#3 arp -s 10.0.0.1 ec:f4:bb:ce:cf:78
#1 sysctl -w net.ipv4.ip_early_demux=0
#1 sysctl -w net.ipv4.conf.default.rp_filter=0
#1 sysctl -w net.ipv4.conf.default.accept_local=1
#1 sysctl -w net.ipv4.conf.default.send_redirects=0
#1 sysctl -w net.ipv4.conf.all.rp_filter=0
#1 sysctl -w net.ipv4.conf.all.accept_local=1
#1 sysctl -w net.ipv4.conf.all.send_redirects=0
#6 systemctl stop firewalld
#6 systemctl disable firewalld
#6 iptables -F ; iptables -t nat -F; iptables -t mangle -F ; ip6tables -F
#6 iptables -X ; iptables -t nat -X; iptables -t mangle -X ; ip6tables -X
#6 iptables -t raw -F ; iptables -t raw -X
#5 modprobe -r ebtable_broute ebtable_nat ebtable_filter ebtables
#3 modprobe -r ipt_SYNPROXY 
#3 modprobe -r nf_synproxy_core 
#3 modprobe -r xt_CT
#3 modprobe -r nf_conntrack_ftp
#3 modprobe -r nf_conntrack_tftp 
#3 modprobe -r nf_conntrack_irc 
#3 modprobe -r nf_nat_tftp ipt_MASQUERADE 
#3 modprobe -r iptable_nat
#3 modprobe -r nf_nat_ipv4 
#3 modprobe -r nf_nat 
#3 modprobe -r nf_conntrack_ipv4 
#3 modprobe -r nf_nat 
#3 modprobe -r nf_conntrack_ipv6 
#3 modprobe -r xt_state
#3 modprobe -r xt_conntrack iptable_raw 
#3 modprobe -r nf_conntrack 
#3 modprobe -r iptable_filter 
#3 modprobe -r iptable_raw
#3 modprobe -r iptable_mangle
#3 modprobe -r ipt_REJECT xt_CHECKSUM 
#3 modprobe -r ip_tables 
#3 modprobe -r nf_defrag_ipv4
#3 modprobe -r ip6table_filter 
#3 modprobe -r ip6_tables 
#3 modprobe -r nf_defrag_ipv6 
#3 modprobe -r ip6t_REJECT 
#3 modprobe -r xt_LOG 
#3 modprobe -r xt_multiport
#3 modprobe -r nf_conntrack
#4 ethtool -K em1 ntuple on
#4 ethtool -K em2 ntuple on
#4 for i in `seq 0 23`
#4 do
#4        ethtool -N em1 flow-type ip4 src-ip 192.168.0.`expr 10 + $i` action $i
#4        ethtool -N em2 flow-type ip4 src-ip 192.168.0.`expr 10 + $i` action $i
#4 done


