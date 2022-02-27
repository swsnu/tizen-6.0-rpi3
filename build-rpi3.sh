#!/bin/bash

############################################
# OSSPR2022                                #
#                                          #
# Builds your ARM64 kernel.                 #
############################################

set -e

# Did you install ccache?
type ccache

# Some cleanups and setups
rm -f arch/arm64/boot/Image
rm -f arch/arm64/boot/dts/broadcom/*.dtb
CROSS_COMPILER='ccache aarch64-linux-gnu-'

# Build .config
make ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILER" tizen_bcmrpi3_defconfig

# Build kernel
make ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILER" -j$(nproc)
