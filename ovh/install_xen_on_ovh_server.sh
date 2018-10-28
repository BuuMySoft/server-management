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

# Removes the volume created during OVH installation
umount /volume
lvremove -f /dev/vg/vg

# Modify Xen to Route
xend_config=/etc/xen/xend-config.sxp
sed -i -e 's/#.*$//' -e 's/^.*vif-bridge.*$//' -e '/^$/d' $xend_config
echo '(network-script network-route)' >> $xend_config
echo '(vif-script vif-route)' >> $xend_config
service xend restart
