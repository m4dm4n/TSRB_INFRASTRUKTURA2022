#!/bin/bash



### 01 CLEARING OLD DATA
if [ -b /dev/nvme0n1p1 ]; then
echo "Partitions found, zapping"
sgdisk -Z /dev/nvme0n1
sgdisk -Z /dev/sda
fi


# Define some variables here
#---------------------------

numberofWininstalls=4

nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(($nvmeSizeinB/1024/1024))
nvmeSizeinGB=$(($nvmeSizeinB/1024/1024/1024))



linEfiPartinMB=300
linSwapinGB=16
linRootinGB=50
linHomeinGB=30

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( $winRecoveryPartinMB / 1024 ))

#---------------------------

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -e -n 7 -p $'Select SSD: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Select HDD: \n' hddVar
echo -e "\n"

#---------------------------

# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#---------------------------


# PARTITIONING

# Create GPT structure on drives
sgdisk  --mbrtogpt /dev/$ssdVar
sgdisk  --mbrtogpt /dev/$hddVar 


# Create Linux HOME partition

sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$ssdVar
sgdisk -n 3:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$ssdVar
sgdisk -n 4:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$ssdVar
sgdisk -p /dev/$ssdVar
#pause
#echo "Done"

# Create Windows partitions

for (( i=1; i<=$numberofWininstalls; i++ ))
do

sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 0:0:+1GiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar

done

# Create BACKUP partition

TotalFreeSectorsNVME=$(sgdisk -p /dev/nvme0n1 | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$((TotalFreeSectorsNVME*512))
TotalFreeinMBNVME=$((TotalFreeinBNVME/1024/1024))
TotalFreeinGBNVME=$((TotalFreeinMBNVME/1024))

sgdisk -p /dev/$ssdVar
pause
clear

winBACKUPinMB=$(($TotalFreeinMBNVME-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-2))
echo "WIN BACKUP SIZE " $winBACKUPinMB



sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 0:0:+"$winBACKUPinMB"MiB -t 0:0700 -c 0:"STORE"  /dev/$ssdVar
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar

# EFI FAT32 FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep EF00 | cut -d " " -f3,4);do mkfs.vfat -F 32 /dev/nvme0n1p$s;done
# LINUX SWAP FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep 8200 | cut -d " " -f3,4);do mkswap /dev/nvme0n1p$s;done
# LINUX ROOT EXT4 FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep 8304 | cut -d " " -f3,4);do mkfs.ext4 /dev/nvme0n1p$s;done
# LINUX HOME EXT4 FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep 8302 | cut -d " " -f3,4);do mkfs.ext4 /dev/nvme0n1p$s;done
# WINDOWS NTFS FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/nvme0n1p$s;done
# WINDOWS RECOVERY NTFS FILESYSTEM
for s in $(sgdisk -p /dev/nvme0n1 | grep 2700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/nvme0n1p$s;done