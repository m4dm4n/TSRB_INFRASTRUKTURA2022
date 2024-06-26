#!/bin/bash

#Create SHARE
#mkdir ~/share
#mount -t cifs //192.168.100.5/WinImages $shareDir -o username=Administrator,password=Tsrb_1234

shareDir="/mnt/share"

#Restore GPT_TABLES
sgdisk -l $shareDir/infrastructureFiles/GPTtableBackups/racLab/pc02Conf/All_Partitions.gpt /dev/nvme0n1
partprobe

#Create Filesystems
for i in {1,5,9,13,17,21,25}; do mkfs.vfat -v -F 32 /dev/nvme0n1p$i; done
mkswap --verbose /dev/nvme0n1p2
for i in {3,4}; do mkfs.ext4 -F -v /dev/nvme0n1p$i; done
for i in {7,8,11,12,15,16,19,20,23,24,27,28}; do mkfs.ntfs -v -Q /dev/nvme0n1p$i; done

#Install Partclone
apt install partclone -y

#Restore LinuxOS
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/linux/efiLinux.pcl -O /dev/nvme0n1p1
partclone.ext4 -r -s $shareDir/infrastructureFiles/images/production/linux/rootLinux.pcl -O /dev/nvme0n1p3
partclone.ext4 -r -s $shareDir/infrastructureFiles/images/production/linux/homeLinux.pcl -O /dev/nvme0n1p4

#Restore Windows OSes
#WIN01
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi5Backup.pcl -O /dev/nvme0n1p5
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p7
ntfsresize --force --force /dev/nvme0n1p7

#WIN02
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi9Backup.pcl -O /dev/nvme0n1p9
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p11
ntfsresize --force --force /dev/nvme0n1p11

#WIN03
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi13Backup.pcl -O /dev/nvme0n1p13
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p15
ntfsresize --force --force /dev/nvme0n1p15

#WIN04
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi17Backup.pcl -O /dev/nvme0n1p17
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p19
ntfsresize --force --force /dev/nvme0n1p19

#WIN05
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi21Backup.pcl -O /dev/nvme0n1p21
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p23
ntfsresize --force --force /dev/nvme0n1p23

#WIN06
partclone.fat32 -r -s $shareDir/infrastructureFiles/images/production/windows/EFI_backups/efi25Backup.pcl -O /dev/nvme0n1p25
partclone.ntfs -r -s $shareDir/infrastructureFiles/images/production/windows/Win10_Partclone/win01NEW.pcl -O /dev/nvme0n1p27
ntfsresize --force --force /dev/nvme0n1p27


#Restore only Linux GPT table
sgdisk -l $shareDir/infrastructureFiles/GPTtableBackups/racLab/pc02Conf/Linux_Partitions.gpt /dev/nvme0n1

reboot
