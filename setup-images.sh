#!/bin/bash

############################################
# OSSPR2022                                #
#                                          #
# Sets up images to boot up QEMU.          #
# You should have built the kernel.        #
############################################

set -ev

TIZEN='tizen-unified_20201020.1_iot-headless-2parts-armv7l-btrfs-rootfs-rpi.tar.gz'
IMAGEDIR='tizen-image'
TMP="$(mktemp -d)"

if [ ! -f "$TIZEN" ]; then
  curl -LO http://download.tizen.org/releases/milestone/tizen/unified/tizen-unified_20201020.1/images/standard/iot-headless-2parts-armv7l-btrfs-rootfs-rpi/tizen-unified_20201020.1_iot-headless-2parts-armv7l-btrfs-rootfs-rpi.tar.gz
fi

rm -rf "$IMAGEDIR"
mkdir -p "$IMAGEDIR"

tar xzvf "$TIZEN" -C "$IMAGEDIR"

sudo mount "$IMAGEDIR/ramdisk.img" "$TMP"
sudo sed -i 's/\/bin\/mount -o remount,ro .//' "$TMP/usr/sbin/init"
sync
sudo umount "$TMP"

sudo ./scripts/mkbootimg_rpi3.sh

cp modules.img boot.img "$IMAGEDIR"
sudo chmod 777 "$IMAGEDIR"/*
