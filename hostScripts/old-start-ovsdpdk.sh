#!/bin/bash

. /root/watson/dpdk-env.sh

#prefix="/usr/local" # used with locally built src
prefix=""  # used with RPMs

vhost="user" # can be user or cuse
eth_model="82599ES" # use XL710 for 40Gb

export DB_SOCK="$prefix/var/run/openvswitch/db.sock"
#network_topology="physdev-to-vm" # two bridges, each with one physdev and one dpdkvhost
network_topology="physdev-to-physdev" # two dkdkvhost devices on one ovs bridge
#network_topology="vm-to-vm" # two dkdkvhost devices on one ovs bridge

# load/unload modules and bind Ethernet cards to dpdk modules
for kmod in fuse vfio vfio-pci; do
	if lsmod | grep -q $kmod; then
	echo "not loading $kmod (already loaded)"
else
	if modprobe -v $kmod; then
		echo "loaded $kmod module"
	else
		echo "Failed to load $kmmod module, exiting"
		exit 1
	fi
fi
done

if [ $vhost = "cuse" ]; then
	if lsmod | grep -q eventfd_link; then
		echo "not loading eventfd_link (already loaded)"
	else
		# if insmod $DPDK_DIR/lib/librte_vhost/eventfd_link/eventfd_link.ko; then
		if insmod /lib/modules/`uname -r`/extra/eventfd_link.ko; then
			echo "loaded eventfd_link module"
		else
			echo "Failed to load eventfd_link module, exiting"
			exit 1
		fi
	fi
fi

dpdk_nics=`lspci -D  | grep $eth_model | awk '{print $1}'`
echo DPDK adapters: $dpdk_nics

dpdk_nic_kmod=vfio-pci # can be vfio or uio_pci_generic or igb_uio

linux_nic_kmod=i40e
if lsmod | grep -q i40e;  then
	echo "unloading $linux_nic_kmod"
	rmmod -v $linux_nic_kmod
fi

# if using igb_uio, load the dpdk (out of kernel tree) igb module
if [ "$dpdk_nic_kmod" == "igb_uio" ]; then
	load_kmod="insmod $DPDK_BUILD/kmod/igb_uio.ko"
else
	load_kmod="modprobe -v $dpdk_nic_kmod"
fi

if lsmod | grep -q $dpdk_nic_kmod; then
	echo "not loading $dpdk_nic_kmod (already loaded)"
else
	if $load_kmod; then
		echo "loaded $dpdk_nic_kmod module"
	else
		echo "Failed to load $dpdk_nic_kmod module, exiting"
		exit 1
	fi
fi

# bind the devices to dpdk module
for nic in $dpdk_nics; do
	dpdk_nic_bind.py --bind $dpdk_nic_kmod $nic
done
dpdk_nic_bind.py --status

# completely remove old ovs configuration
killall ovs-vswitchd
killall ovsdb-server
killall ovsdb-server ovs-vswitchd
sleep 3
rm -rf $prefix/var/run/openvswitch/ovs-vswitchd.pid
rm -rf $prefix/var/run/openvswitch/ovsdb-server.pid
rm -rf $prefix/var/run/openvswitch/*
rm -rf $prefix/etc/openvswitch/*db*
rm -rf $prefix/var/log/openvswitch/*

# start new ovs
mkdir -p $prefix/var/run/openvswitch
mkdir -p $prefix/etc/openvswitch
$prefix/bin/ovsdb-tool create $prefix/etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema

rm -rf /dev/usvhost-1
$prefix/sbin/ovsdb-server -v --remote=punix:$DB_SOCK \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --pidfile --detach || exit 1

if [ $vhost == "cuse" ]; then
	cuse_dev_opt="--cuse_dev_name usvhost-1"
fi

screen -dmS ovs \
sudo su -g qemu -c "umask 002; $prefix/sbin/ovs-vswitchd --dpdk $cuse_dev_opt -c 0x1 -n 3 --socket-mem 1024,1024 -- unix:$DB_SOCK --pidfile --log-file=$prefix/var/log/openvswitch/ovs-vswitchd.log >/tmp/ovs.log 2>&1"

$prefix/bin/ovs-vsctl --no-wait init

case $network_topology in
	"vm-to-vm")
	# create a bridge with 2 virt devs per bridge, to be used to connect to 2 VMs
	$prefix/bin/ovs-vsctl --if-exists del-br ovsbr0
	$prefix/bin/ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
	$prefix/bin/ovs-vsctl add-port ovsbr0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
	$prefix/bin/ovs-vsctl add-port ovsbr0 vhost-user3 -- set Interface vhost-user3 type=dpdkvhostuser
	$prefix/bin/ovs-ofctl del-flows ovsbr0
	$prefix/bin/ovs-ofctl add-flow ovsbr0 "in_port=1,idle_timeout=0 actions=output:2"
	$prefix/bin/ovs-ofctl add-flow ovsbr0 "in_port=2,idle_timeout=0 actions=output:1"

	$prefix/bin/ovs-vsctl --if-exists del-br ovsbr1
	$prefix/bin/ovs-vsctl add-br ovsbr1 -- set bridge ovsbr1 datapath_type=netdev
	$prefix/bin/ovs-vsctl add-port ovsbr1 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
	$prefix/bin/ovs-vsctl add-port ovsbr1 vhost-user4 -- set Interface vhost-user4 type=dpdkvhostuser
	$prefix/bin/ovs-ofctl del-flows ovsbr1
	$prefix/bin/ovs-ofctl add-flow ovsbr1 "in_port=1,idle_timeout=0 actions=output:2"
	$prefix/bin/ovs-ofctl add-flow ovsbr1 "in_port=2,idle_timeout=0 actions=output:1"
	;;
	"physdev-to-vm")
	# create the bridges/ports with 1 phys dev and 1 virt dev per bridge, to be used for 1 VM to forward packets
	$prefix/bin/ovs-vsctl --if-exists del-br ovsbr0
	$prefix/bin/ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
	$prefix/bin/ovs-vsctl add-port ovsbr0 dpdk0 -- set Interface dpdk0 type=dpdk
	$prefix/bin/ovs-vsctl add-port ovsbr0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
	$prefix/bin/ovs-ofctl del-flows ovsbr0
	$prefix/bin/ovs-ofctl add-flow ovsbr0 "in_port=1,idle_timeout=0 actions=output:2"
	$prefix/bin/ovs-ofctl add-flow ovsbr0 "in_port=2,idle_timeout=0 actions=output:1"
	
	$prefix/bin/ovs-vsctl --if-exists del-br ovsbr1
	$prefix/bin/ovs-vsctl add-br ovsbr1 -- set bridge ovsbr1 datapath_type=netdev
	$prefix/bin/ovs-vsctl add-port ovsbr1 dpdk1 -- set Interface dpdk1 type=dpdk
	$prefix/bin/ovs-vsctl add-port ovsbr1 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
	$prefix/bin/ovs-ofctl del-flows ovsbr1
	$prefix/bin/ovs-ofctl add-flow ovsbr1 "in_port=1,idle_timeout=0 actions=output:2"
	$prefix/bin/ovs-ofctl add-flow ovsbr1 "in_port=2,idle_timeout=0 actions=output:1"
	;;
	"physdev-to-physdev")
	# create the bridges/ports with 1 phys dev and 1 virt dev per bridge, to be used for 1 VM to forward packets
	for dev_pair in 1; do
		br="ovsbr`echo "$dev_pair - 1" | bc`"
		port_a="dpdk`echo "$dev_pair * 2 - 2" | bc`"
		port_b="dpdk`echo "$dev_pair * 2 - 1" | bc`"
		$prefix/bin/ovs-vsctl --if-exists del-br $br
		$prefix/bin/ovs-vsctl add-br $br -- set bridge $br datapath_type=netdev
		$prefix/bin/ovs-vsctl add-port $br $port_a -- set Interface $port_a type=dpdk
		$prefix/bin/ovs-vsctl add-port $br $port_b -- set Interface $port_b type=dpdk
		$prefix/bin/ovs-ofctl del-flows $br
		$prefix/bin/ovs-ofctl add-flow $br "in_port=1,idle_timeout=0 actions=output:2"
		$prefix/bin/ovs-ofctl add-flow $br "in_port=2,idle_timeout=0 actions=output:1"
	done
esac

#chown qemu.qemu /var/run/openvswitch/vhost-user*
