#!/bin/bash

pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,7,9,11,13,15,17,19,21 --socket-mem 1024,1024\
  -n 4 --proc-type auto  --file-prefix pg  -w 0000:83:00.0 -w 0000:83:00.1\
  -- -N -T -P -m "[7/9:11/13].0, [15/17:19/21].1" -l pktgen.log -f pktgen.pkt
