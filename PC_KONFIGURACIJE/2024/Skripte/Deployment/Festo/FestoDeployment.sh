#!/bin/bash

#Create SHARE
#mkdir ~/share
#mount -t cifs //192.168.100.5/WinImages $shareDir/share -o username=Administrator

shareDir=/home/ubuntu

#Restore GPT_TABLES
sgdisk -l $shareDir/share/GPTTablice/FestoTablice/All_Partitions.gpt /dev/nvme0n1
partprobe

#Create Filesystems
for i in {1,5,9}; do mkfs.vfat -F 32 /dev/nvme0n1p$i; done
mkswap /dev/nvme0n1p2
for i in {3,4}; do mkfs.ext4 -F /dev/nvme0n1p$i; done
for i in {7,8,11,12}; do mkfs.ntfs -Q /dev/nvme0n1p$i; done

#Install Partclone
apt install partclone -y

#Restore LinuxOS
partclone.fat32 -r -s $shareDir/share/Images/NEW_Linux/efiLinux.pcl -O /dev/nvme0n1p1
partclone.ext4 -r -s $shareDir/share/Images/NEW_Linux/rootLinux.pcl -O /dev/nvme0n1p3
partclone.ext4 -r -s $shareDir/share/Images/NEW_Linux/homeLinux.pcl -O /dev/nvme0n1p4

#Restore Windows OSes
#WIN01
partclone.fat32 -r -s $shareDir/share/Images/Windows/EFI_backups/efi5Backup.pcl -O /dev/nvme0n1p5
partclone.ntfs -r -s $shareDir/share/Images/Windows/Win10_01_Partclone/win01NEW.pcl -O /dev/nvme0n1p7
ntfsresize --force --force /dev/nvme0n1p7

#WIN02
partclone.fat32 -r -s $shareDir/share/Images/Windows/EFI_backups/efi9Backup.pcl -O /dev/nvme0n1p9
partclone.ntfs -r -s $shareDir/share/Images/Windows/Win10_01_Partclone/win01NEW.pcl -O /dev/nvme0n1p11
ntfsresize --force --force /dev/nvme0n1p11

#Restore only Linux GPT table
sgdisk -l $shareDir/share/GPTTablice/RacTablice/Linux_Partitions.gpt /dev/nvme0n1

reboot
