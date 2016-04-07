#!/bin/bash
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -D INPUT 7
iptables -D FORWARD 9
arp -s 10.0.0.1 ec:f4:bb:ce:cf:78
