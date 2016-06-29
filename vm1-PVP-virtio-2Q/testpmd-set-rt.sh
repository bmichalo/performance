#!/bin/bash

echo "-1" >/proc/sys/kernel/sched_rt_runtime_us
sleep 1
testpmd_pid=`ps aux | grep test-pmd | grep -v grep | awk '{print $2}'`
pushd /proc/$testpmd_pid/task
for i in `/bin/ls`; do
	grep lcore-slave $i/stat && chrt -f -p 95 $i
done
popd
