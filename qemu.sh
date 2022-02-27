#!/bin/bash

############################################
# OSSPR2022                                #
#                                          #
# Boots up your kernel with QEMU.          #
# Make sure you built the kernel and       #
# setup images in ./tizen-image.           #
############################################

exec qemu-system-aarch64           `# The QEMU system emulator `\
  -gdb tcp::1234                   `# Open a gdbserver on port 1234 for debugging `\
  -nographic                       `# We don't use the graphical environment `\
  -serial mon:stdio                `# Redirect the virtual serial port to QEMU stdio (including ctrl-c) `\
  -M virt                          `# Machine type is 'virt', QEMU's virtual hardware platform `\
  -cpu cortex-a53                  `# ARM Cortex A53, provided by the 'virt' platform `\
  -smp cores=4                     `# Four cores - this is a multicore machine! `\
  -m 2048                          `# 2GB RAM for Tizen `\
  -kernel ./arch/arm64/boot/Image  `# The kernel image that we built `\
  `# Initial RAM disk image, used during booting `\
  `# Check out https://www.kernel.org/doc/html/v4.19/admin-guide/initrd.html `\
  -initrd tizen-image/ramdisk.img  \
  `# Append this string to the Linux kernel commandline parameters `\
  `# Check out https://www.kernel.org/doc/html/v4.19/admin-guide/kernel-parameters.html `\
  -append "root=/dev/ram0 rw kgdboc=ttyS0,115200 kgdbwait nokaslr rodata=off"  \
  `# Create a virtual drive from each image file and attach them to our virtual machine `\
  `# Tizen's initrd init process discovers these and mounts them appropriately `\
  `# Check out usr/sbin/init in tizen-image/ramdisk.img `\
  -drive file=tizen-image/rootfs.img,format=raw,if=none,id=rootfs -device virtio-blk-device,drive=rootfs  \
  -drive file=tizen-image/boot.img,format=raw,if=none,id=boot -device virtio-blk-device,drive=boot  \
  -drive file=tizen-image/modules.img,format=raw,if=none,id=modules -device virtio-blk-device,drive=modules  \
  -drive file=tizen-image/system-data.img,format=raw,if=none,id=system-data -device virtio-blk-device,drive=system-data
