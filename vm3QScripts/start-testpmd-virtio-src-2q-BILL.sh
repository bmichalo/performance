#!/bin/bash

testpmd -l 0,1,2,3,4 --socket-mem 1024\
  -n 4 --proc-type auto --file-prefix pg -w 0000:00:06.0 -w 0000:00:07.0\
  -- --portmask=3 \
  --disable-hw-vlan --disable-rss \
  -i --rxq=2 --txq=2 --rxd=256 --txd=256\
  --auto-start --nb-cores=4
