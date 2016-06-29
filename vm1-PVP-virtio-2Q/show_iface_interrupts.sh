#!/bin/bash
watch -n0.1 --no-title "grep -e CPU0 -e virtio /proc/interrupts"
