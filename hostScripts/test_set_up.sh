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
ethtool -L em2 combined 12
ethtool -L em1 combined 12
tuna -q em1-TxRx* -S0 -m -x
tuna -q em2-TxRx* -S0 -m -x
rmmod ebtable_broute ebtable_nat ebtable_filter ebtables
