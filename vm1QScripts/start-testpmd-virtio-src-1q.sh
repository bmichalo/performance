#!/bin/bash

/root/dpdk/x86_64-native-linuxapp-gcc/build/app/test-pmd/testpmd -l 1,2,3,4 --socket-mem 1024\
  -n 2 --proc-type auto --file-prefix pg -w 0000:00:06.0 -w 0000:00:07.0\
  -- --portmask=3 \
  --disable-hw-vlan --disable-rss \
  -i --rxq=1 --txq=1 --rxd=256 --txd=256\
  --auto-start --nb-cores=2
