#!/bin/bash



# Define some variables here
#---------------------------

nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(( nvmeSizeinB / 1024 / 1024 ))
nvmeSizeinGB=$(( nvmeSizeinB / 1024 / 1024 / 1024 ))
hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
hddSizeinMB=$(( hddSizeinB / 1024 / 1024 ))
hddSizeinGB=$(( hddSizeinB / 1024 / 1024 / 1024 ))


winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(($winRecoveryPartinMB/1024))

#---------------------------

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -e -n 7 -p $'Odaberi SSD iz popisa: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Odaberi HDD iz popisa: \n' hddVar
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

winBackupPartinMB=30000
winSystemPartinMB=$(( nvmeSizeinMB - winEfiPartinMB - msrPartinMB - winRecoveryPartinMB - 30000 - 2 ))
winSystemPartinGB=$(( winSystemPartinMB / 1024 ))
echo "Velicina Windows Sistemske Particije: " $winSystemPartinGB "GB"
echo -e "\n"
winDataPartinMB=$(( hddSizeinMB - 2 ))

echo "Stvaram GPT strukturu na diskovima"
sgdisk --mbrtogpt /dev/$ssdVar >/dev/null 2>&1
sgdisk --mbrtogpt /dev/$hddVar >/dev/null 2>&1
echo "Gotovo"

echo "Stvaram particije na SSD disku"
sgdisk -n 1:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar >/dev/null 2>&1
sgdisk -n 2:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar >/dev/null 2>&1
sgdisk -n 3:0:+"$winSystemPartinMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar >/dev/null 2>&1
sgdisk -n 4:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar >/dev/null 2>&1
sgdisk -n 5:0:+"$winBackupPartinMB"MiB -t 0:0700 -c 0:"BACKUP"  /dev/$ssdVar >/dev/null 2>&1
echo "Gotovo"

echo "Stvaram particije na HDD disku"
sgdisk -n 1:0:+"$winDataPartinMB"MiB -t 0:0700 -c 0:"DATA" /dev/$hddVar >/dev/null 2>&1
echo "Gotovo"

echo "Ispisujem GPT tablice"
sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar
pause

