#!/bin/bash



for i in {1,5,9,13,17,21,25}; do mkfs.vfat -v -F 32 /dev/nvme0n1p$i; done

mkswap --verbose /dev/nvme0n1p2

for i in {3,4}; do mkfs.ext4 -v /dev/nvme0n1p$i; done

for i in {7,8,11,12,15,16,19,20,23,24,27,28}; do mkfs.ntfs -v -Q /dev/nvme0n1p$i; done
