#!/bin/bash

# Define start variables

export saveDIR=~/BACKUP

# Define some functions

function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}


# CREATE GPT TABLE PACKAGES


sudo fdisk -l | grep "Disk /dev/sd"

read -n 3 -p $'Select SSD: \n' ssdvar
read -n 3 -p $'Select HDD: \n' hddvar

#
# CREATE LINUX 1
#

# DEAL WITH HDD FIRST
#Deleting rest of partitions
for i in {5..53}
do
sudo sgdisk --delete=$i /dev/$hddvar
done
sudo sgdisk --sort /dev/$hddvar
sudo sgdisk -p /dev/$hddvar
pause

#Creating Filesystems
sudo mkfs.vfat -v /dev/$hddvar\1
sudo mkswap -v /dev/$hddvar\2
sudo mkfs.ext4 -v /dev/$hddvar\3
sudo mkfs.ext4 -v /dev/$hddvar\4
pause

#Saving to a backup file
sudo sgdisk --backup=$saveDIR/HDD/Linux1/01_HDD_Linux1.gpt /dev/$hddvar
pause 

#Restoring all partitions
sudo sgdisk --load-backup=$saveDIR/HDD/00_HDD_ALLPARTITIONS.gpt /dev/$hddvar
pause

# NOW DEAL WITH SSD
#Deleting rest of partitions
for i in {2..11}
do
sudo sgdisk --delete=$i /dev/$ssdvar
done
sudo sgdisk --sort /dev/$ssdvar
sudo sgdisk -p /dev/$ssdvar
pause

#Creating Filesystems
sudo mkfs.ntfs -v /dev/$ssdvar\1
pause 

#Saving to a backup file
sudo sgdisk --backup=$saveDIR/SSD/Linux1/01_SSD_Linux1.gpt /dev/$ssdvar
pause 
#Restoring all partitions
sudo sgdisk --load-backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/$ssdvar
pause 

#
# CREATE LINUX 2
#

#
# CREATE GEN1 WINDOWS10
#

#
# CREATE GEN2 WINDOWS10
#

#
# CREATE GEN3 WINDOWS10
#

#
# CREATE GEN4 WINDOWS10
#

#
# CREATE GEN5 WINDOWS10
#



#
# CREATE RAZNO WINDOWS10
#


#
# CREATE SEM1 WINDOWS10
#

#
# CREATE SEM2 WINDOWS10
#


#
# CREATE STORE WINDOWS10
#
