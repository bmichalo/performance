#!/bin/bash

pktgen -d /usr/lib64/librte_pmd_virtio_uio.so -l 1,2,3 --socket-mem 1024\
  -n 4 --proc-type auto  --file-prefix pg  -w 0000:00:06.0 -w 0000:00:07.0\
  -- -N -T -P -m "[2].0, [3].1" -l pktgen.log 
