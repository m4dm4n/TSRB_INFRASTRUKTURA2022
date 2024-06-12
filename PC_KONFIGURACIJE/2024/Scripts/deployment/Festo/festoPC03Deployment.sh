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
sgdisk -l $shareDir/GPTTables/festoGPT03/festoAll_Partitions.gpt /dev/nvme0n1
sgdisk -l $shareDir/GPTTables/festoGPT03/festoAll_Data_Partitions.gpt /dev/sda
sleep 1
partprobe
sleep 5
sgdisk -p /dev/nvme0n1
sgdisk -p /dev/sda
#Create Filesystems
for i in {1,5,9}; do mkfs.vfat -F 32 /dev/nvme0n1p$i; done
mkswap --verbose /dev/nvme0n1p2
for i in {3,4}; do mkfs.ext4 -F /dev/nvme0n1p$i; done
for i in {7,8,11,12}; do mkfs.ntfs -Q /dev/nvme0n1p$i; done
for i in {1,2}; do mkfs.ntfs -Q /dev/sda$i; done


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
rsync -ah --progress $shareDir/Images/windows/win10Partclone/win01NEW.pcl $tempDir/images/strippy/Images/

# Add Festo tag file for PC configuration identification
touch $tempDir/images/student/Skripte/festoTag


#Restore Windows OSes
#WIN01
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi5Backup.pcl -O /dev/nvme0n1p5
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p7
ntfsresize --force --force /dev/nvme0n1p7

#WIN02
partclone.fat32 -r -s $tempDir/images/strippy/Images/efi9Backup.pcl -O /dev/nvme0n1p9
partclone.ntfs -r -s $tempDir/images/strippy/Images/win01NEW.pcl -O /dev/nvme0n1p11
ntfsresize --force --force /dev/nvme0n1p11

#Restore only Linux GPT table
sgdisk -l $shareDir/GPTTables/festoGPT03/festoLinux_Partitions.gpt /dev/nvme0n1

#Unmount the images directory
umount $tempDir/images


#Reboot the system
reboot
