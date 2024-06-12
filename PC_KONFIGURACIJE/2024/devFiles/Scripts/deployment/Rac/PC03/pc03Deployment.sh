#!/bin/bash

#########
## Set some error handling options
set -o errexit     # It will exit on first error in script
set -o pipefail    #It will exit on first error in some pipeline
#########

#########
# Check if the script is run as root
if [ "$EUID" -ne 0 ]
   then echo "Run the script with root permissions (sudo ./scriptname.sh)"
   exit 1
fi
#########

shareDir=/tmp/share

#Restore GPT_TABLES
sgdisk -l $shareDir/GPTTables/GPT02/pc02All_Partitions.gpt /dev/nvme0n1
sgdisk -l $shareDir/GPTTables/GPT0304/pc0304All_Data_Partitions.gpt /dev/sda
sleep 1
partprobe
sleep 5
sgdisk -p /dev/nvme0n1
sgdisk -p /dev/sda
#Create Filesystems
for i in {1,5,9,13,17,21,25}; do mkfs.vfat -F 32 /dev/nvme0n1p$i; done
mkswap --verbose /dev/nvme0n1p2
for i in {3,4}; do mkfs.ext4 -F /dev/nvme0n1p$i; done
for i in {7,8,11,12,15,16,19,20,23,24,27,28}; do mkfs.ntfs -Q /dev/nvme0n1p$i; done
for i in {1..5}; do mkfs.ntfs -Q /dev/sda$i; done


#Install Partclone
apt install partclone -y

#Restore LinuxOS
partclone.fat32 -r -s $shareDir/Images/linux/efiLinux.pcl -O /dev/nvme0n1p1
partclone.ext4 -r -s $shareDir/Images/linux/rootLinux.pcl -O /dev/nvme0n1p3
partclone.ext4 -r -s $shareDir/Images/linux/homeLinux.pcl -O /dev/nvme0n1p4

#Copy EFI, Linux root, and Windows backup images to the local home directory
tempDir=/tmp
mkdir -p $tempDir/images
mount -t ext4 /dev/nvme0n1p4 $tempDir/images
if [ ! -d "$tempDir/images/strippy/Images" ]; then
    mkdir -p "$tempDir/images/strippy/Images"
fi
rsync -ah --progress $shareDir/Images/linux/efiLinux.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/linux/rootLinux.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi5Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi9Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi13Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi17Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi21Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/efi/efi25Backup.pcl $tempDir/images/strippy/Images/
rsync -ah --progress $shareDir/Images/windows/win10Partclone/win01NEW.pcl $tempDir/images/strippy/Images/

#Restore Windows OSes
#WIN01
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi5Backup.pcl -O /dev/nvme0n1p5
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p7
ntfsresize --force --force /dev/nvme0n1p7

#WIN02
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi9Backup.pcl -O /dev/nvme0n1p9
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p11
ntfsresize --force --force /dev/nvme0n1p11

#WIN03
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi13Backup.pcl -O /dev/nvme0n1p13
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p15
ntfsresize --force --force /dev/nvme0n1p15

#WIN04
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi17Backup.pcl -O /dev/nvme0n1p17
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p19
ntfsresize --force --force /dev/nvme0n1p19

#WIN05
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi21Backup.pcl -O /dev/nvme0n1p21
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p23
ntfsresize --force --force /dev/nvme0n1p23

#WIN06
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi25Backup.pcl -O /dev/nvme0n1p25
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p27
ntfsresize --force --force /dev/nvme0n1p27


#Restore only Linux GPT table
sgdisk -l $shareDir/GPTTables/GPT02/pc02Linux_Partitions.gpt /dev/nvme0n1


#Unmount the images directory
umount $tempDir/images


#Reboot the system
reboot
