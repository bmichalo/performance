#!/bin/bash
killall irqbalance
#tuned-adm profile network-throughput 
tuned-adm profile network-latency 
ethtool -G p2p1 tx 80 rx 256
ethtool -G p2p2 tx 80 rx 256
ethtool -K p2p1 gro off lro off
ethtool -K p2p2 gro off lro off
ethtool -C p2p1 rx-usecs 25
ethtool -C p2p2 rx-usecs 25
ifconfig p2p1 down
ifconfig p2p2 down
sleep 1
ethtool -L p2p2 combined 2
ethtool -L p2p1 combined 2 
sleep 1
ifconfig p2p1 up 
ifconfig p2p2 up 
sleep 1
#tuna -q p2p1-TxRx* -S1 -m -x
#tuna -q p2p2-TxRx* -S1 -m -x
tuna -q p2p1-TxRx* --cpus=1,3 -m -x
tuna -q p2p2-TxRx* --cpus=5,7 -m -x
#7 tuna -q em1-TxRx* -S0,1 -m -x
#7 tuna -q em2-TxRx* -S0,1 -m -x
#echo "1" > /proc/sys/net/ipv4/ip_forward
#iptables -D INPUT 7
#iptables -D FORWARD 9
#arp -s 10.0.0.1 ec:f4:bb:ce:cf:78
sysctl -w net.ipv4.ip_early_demux=0
sysctl -w net.ipv4.conf.default.rp_filter=0
sysctl -w net.ipv4.conf.default.accept_local=1
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.all.accept_local=1
sysctl -w net.ipv4.conf.all.send_redirects=0
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
