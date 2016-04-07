#!/bin/bash

ifconfig ens7 up
ifconfig ens6 up
brctl addbr br0
ifconfig br0 up
brctl addif br0 ens6
brctl addif br0 ens7
