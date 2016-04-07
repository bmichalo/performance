#!/usr/bin/bash

for interface in $(ls /sys/class/net/);
do
    for txqueue in $(ls /sys/class/net/$interface/queues/*tx*/xps_cpus)
        do
            echo $interface
            cat $txqueue 
        done
done
