#!/bin/bash


# echo  pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,5,6,7,8,9,10,11,12,13,14,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "5.0, 7.1, 9.2, 11.3, 13.4, 15.5, 4.6, 6.7, 8.8, 10.9, 12.10, 14.11" -l ptkgen.log

# pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4,6,8,10,12,14,5,7,9,11,13,15 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg $pci_devs_opt -- -N -T -P -m "[4].0, [6].1, [8].2, [10].3, [12].4, [14].5, [5].6, [7].7, [9].8, [11].9, [13].10, [15].11" -l ptkgen.log -f pktgen.pkt
pktgen -d /usr/lib64/librte_pmd_i40e.so -l 1,4 --socket-mem 1024,1024 -n 4 --proc-type auto --file-prefix pg -w "0000:04:02.1" -- -N -T -P -m "[4].0" -l ptkgen.log 

