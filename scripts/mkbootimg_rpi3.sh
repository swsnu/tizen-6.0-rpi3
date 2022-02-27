#!/bin/bash

BOOT_PATH="rpi3/boot"
USER_ID=`id -u`
GROUP_ID=`id -g`
IS_64BIT=`cat .config | grep CONFIG_64BIT`

rm -f boot.img
rm -rf tmp
mkdir tmp

# Create boot.img
mkfs.vfat -F 16 -C -n BOOT boot.img 65536
sudo mount -o loop,uid=$USER_ID,gid=$GROUP_ID,showexec boot.img ./tmp
if [ -n "$IS_64BIT" ]; then
	echo "Create 64bit boot image"
	cp $BOOT_PATH/config_64bit.txt ./tmp/config.txt
else
	echo "Create 32bit boot image"
	cp $BOOT_PATH/config_32bit.txt ./tmp/config.txt
fi
cp $BOOT_PATH/LICENCE.broadcom ./tmp
cp $BOOT_PATH/fixup*.dat ./tmp
if [ -n "$IS_64BIT" ]; then
	cp arch/arm64/boot/Image ./tmp
	cp arch/arm64/boot/dts/broadcom/bcm*.dtb ./tmp
else
	cp arch/arm/boot/zImage ./tmp
	cp arch/arm/boot/dts/bcm*.dtb ./tmp
fi

# install u-boot files extracted from u-boot-rpi3 rpm package in download.tizen.org.
TMP_UBOOT_PATH=tmp_uboot
mkdir -p ${TMP_UBOOT_PATH}
pushd ${TMP_UBOOT_PATH}
if [ -n "$IS_64BIT" ]; then
	REPO_URL=http://download.tizen.org/snapshots/tizen/unified/latest/repos/standard/packages/aarch64/
else
	REPO_URL=http://download.tizen.org/snapshots/tizen/unified/latest/repos/standard/packages/armv7l/
fi
rm -f index.html*
wget ${REPO_URL}
UBOOT=`awk -F\" '{ print $2 }' index.html | grep u-boot-rpi3`
wget ${REPO_URL}${UBOOT}
unrpm ${UBOOT}

# install u-boot.img having optee.bin extracted from atf-rpi3 rpm package in download.tizen.org.
if [ -n "$IS_64BIT" ]; then
	ATF=`awk -F\" '{ print $2 }' index.html | grep atf-rpi3`
	wget ${REPO_URL}${ATF}
	unrpm ${ATF}
fi

popd
cp -a ${TMP_UBOOT_PATH}/boot/* ./tmp
rm -rf ${TMP_UBOOT_PATH}

sync
sudo umount tmp

rm -f modules.img
mkdir -p tmp/lib/modules
mkdir -p tmp_modules

# Create modules.img
dd if=/dev/zero of=modules.img bs=1024 count=20480
mkfs.ext4 -q -F -t ext4 -b 1024 -L modules modules.img
sudo mount -o loop modules.img ./tmp/lib/modules
if [ -n "$IS_64BIT" ]; then
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
else
	export ARCH=arm
	export CROSS_COMPILE=arm-linux-gnueabi-
fi
make modules_install INSTALL_MOD_PATH=./tmp_modules INSTALL_MOD_STRIP=1
sudo mv ./tmp_modules/lib/modules/* ./tmp/lib/modules
sudo -n chown root:root ./tmp/lib/modules -R

sync
sudo umount tmp/lib/modules

rm -rf tmp tmp_modules
