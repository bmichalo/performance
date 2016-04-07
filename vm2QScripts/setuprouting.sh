ysctl -w net.ipv4.ip_early_demux=0
sysctl -w net.ipv4.conf.default.rp_filter=0
sysctl -w net.ipv4.conf.default.accept_local=1
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.all.accept_local=1
sysctl -w net.ipv4.conf.all.send_redirects=0
ifconfig p1p1 txqueuelen 64
ifconfig p1p2 txqueuelen 64

# RHEL 7.1 prefers tx ring size of 96, 7.2 and newer use 80
ethtool -G p1p1 tx 80 rx 256
ethtool -G p1p2 tx 80 rx 256

ethtool -C p1p1 rx-usecs 25
ethtool -C p1p2 rx-usecs 25

ethtool -K p1p1 gro off lro off
ethtool -K p1p2 gro off lro off

