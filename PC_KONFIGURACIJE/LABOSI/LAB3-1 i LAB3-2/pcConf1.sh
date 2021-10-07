#!/bin/bash

# Available different locations and configurations
# PRAKSA_ELEKTROTEHNIKA_NASTAVNICKO (3)
# PRAKSA_STROJARSTVO_NASTAVNICKO (1)
# PRAKSA_STROJARSTVO_UCENICKO (6)
# KABINETI (8)
# LAB21_22 NASTAVNICKO (2)
# LAB21_22 UCENICKO (24)


# Define some variables here
#---------------------------

nvmeSizeGB=$(fdisk -l | grep nvme | cut -d " " -f3)
nvmeSizeMB=$(($nvmeSizeGB*1024))
hddSizeGB=$(fdisk -l | grep sdb | cut -d " " -f3)
hddSizeMB=$(($hddSizeGB*1024))


linEfiPartMB=300
linSwapGB=16
linRootMB=50
linHomeMB=30

winEfiPartMB=300
msrPartMB=128
winRecoveryPartMB=10240
winRecoveryPartGB=$(($winRecoveryPart/1024))

#---------------------------

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -n 7 -p $'Select SSD: \n' ssdVar
echo -e "\n"
read -n 3 -p $'Select HDD: \n' hddVar
echo -e "\n"

#---------------------------

# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#---------------------------

# KABINETI PARTITIONING

# Calculate Windows System partition size

winSystemPartMB=$(($nvmeSizeMB-$winEfiPartMB-$msrPartMB-$winRecoveryPartMB-100))
echo "Windows System Partition size is: " $winSystemPartMB "MB"
echo -e "\n"


sgdisk  --mbrtogpt /dev/$ssdVar
sgdisk --pretend --mbrtogpt /dev/$hddVar 

sgdisk -n 1:0:+"$winEfiPartMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar

sgdisk -n 2:0:+"$msrPartMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar

sgdisk -n 3:0:+"$winSystemPartMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar

sgdisk -n 4:0:+"$winRecoveryPartMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar


sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar
pause

