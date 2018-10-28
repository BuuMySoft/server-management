#!/bin/bash
###############################################################################
# Creates a distribution image file
###############################################################################
# Distribution
dist=stretch
if [[ ! -z $1 ]]; then
	dist=$1
fi
# Initialization scripts
script_file=$2
# Create an empty image file:
image=$(mktemp /tmp/${dist}.XXXXXXXXX.img)
dd if=/dev/zero of=${image} bs=1024 count=0 seek=$[2*1024*1024]
# Create filesystem 
mkfs.ext4 -F ${image}
# Creates directory to stock the distribution
dist_dir=$(mktemp -d /tmp/${dist}.XXXXXXXXX)
# Mounts the image file
mount ${image} $dist_dir
# Installation via debootstrap
debootstrap --arch=amd64 $dist $dist_dir http://debian.mirrors.ovh.net/debian/
chroot_script=$dist_dir/$(mktemp chroot_XXXXXXXX)
if [[ ! -z $script_file ]]; then
	cat $script_file > $chroot_script	
fi
chmod u+x $chroot_script
# chroot to install additional packages 
chroot $dist_dir /$(basename $chroot_script) 
rm -fr $chroot_script
# Generates tar file 
cd $dist_dir 
tar czf ~/${dist}.img.tar.gz . --numeric-owner
cd 
umount $dist_dir