#!/bin/bash

ifconfig eth2 up
ifconfig eth1 up
brctl addbr br0
ifconfig br0 up
brctl addif br0 eth2
brctl addif br0 eth1
