#!/bin/bash

# Available different locations and configurations
# LAB31_32_NASTAVNICKO (2)
# LAB31_32_UCENICKO (24)

# Define some variables here
#---------------------------

nvmeSizeinGB=$(fdisk -l | grep nvme | cut -d " " -f3)
nvmeSizeinMB=$(($nvmeSizeinGB*1024))
hddSizeinGB=$(fdisk -l | grep sdb | cut -d " " -f3)
hddSizeinMB=$(($hddSizeinGB*1024))


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