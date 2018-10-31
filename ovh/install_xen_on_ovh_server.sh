#!/bin/sh
###############################################################################
# This script is aimed to be used as a post installation script to
# install an OVH dedicated server.
# This script installs Xen.
##############################################################################

# Installs Xen
xen_version=$(apt-cache search xen-linux-system | sed 's/-/ /g' | awk '{ print $4 }')
apt-get install -qqy xen-hypervisor xen-linux-system-$xen_version xen-utils xen-tools

# Changes boot order
dpkg-divert --divert /etc/grub.d/08_linux_xen --rename /etc/grub.d/20_linux_xen
update-grub

# Creates the volume
# We assume that during OVH configuration
# the partition is called to_be_removed
dev=$(grep to_be_removed /etc/fstab | awk '{ print $1 }')
mount_point=/to_be_removed
volume=vg
umount $mount_point
pvcreate -f $dev
vgcreate $volume
sed -i -e '/to_be_removed/d' /etc/fstab

# Needed to create bridge interfaces
apt-get -qqy install bridge-utils

# Modify Xen to use Route
xend_config=/etc/xen/xend-config.sxp
sed -i -e 's/#.*$//' -e 's/^.*vif-bridge.*$//' -e '/^$/d' $xend_config
echo '(network-script network-route)' >> $xend_config
echo '(vif-script vif-route)' >> $xend_config
service xend restart

# Networking
cat <<EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
EOF

xen_bridge=xenbr0
interface=$(ip -f inet a s | grep BROADCAST | awk '{ print $2 }' | sed -e 's/://')
ip=$(ip -f inet a s | grep inet | grep $interface | awk '{ print $2 }' | sed -e 's/\/24//')
ip_without_last=$(echo $ip | sed -e 's/\./ /g' | awk '{ print $1"."$2"."$3 }')
cat <<EOF > /etc/network/interfaces.d/10_xenbr0
# Xen bridge
auto $xen_bridge
iface $xen_bridge inet static
bridge_ports $interface
      address   ${ip_without_last}.147
      netmask   255.255.255.0
      network   ${ip_without_last}.0
      gateway   ${ip_without_last}.254
      broadcast ${ip_without_last}.255
EOF
