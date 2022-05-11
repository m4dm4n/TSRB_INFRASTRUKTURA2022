#!/bin/bash



# Define some variables here
#---------------------------

nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(($nvmeSizeinB/1024/1024))
nvmeSizeinGB=$(($nvmeSizeinB/1024/1024/1024))
hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
hddSizeinMB=$(($hddSizeinB/1024/1024))
hddSizeinGB=$(($hddSizeinB/1024/1024/1024))



linEfiPartinMB=300
linSwapinGB=16
linRootinMB=50
linHomeinMB=30

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(($winRecoveryPartinMB/1024))

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

winBackupPartinMB=30000
winSystemPartinMB=$(($nvmeSizeinMB-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-$winBackupPartinMB-2))
echo "Windows System Partition size is: " $winSystemPartinMB "MB"
echo -e "\n"
winDataPartinMB=$(($hddSizeinMB-2))

sgdisk  --mbrtogpt /dev/$ssdVar
sgdisk --pretend --mbrtogpt /dev/$hddVar 

sgdisk -n 1:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 2:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 3:0:+"$winSystemPartinMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar
sgdisk -n 4:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar
sgdisk -n 5:0:+"$winBackupPartinMB"MiB -t 0:0700 -c 0:"BACKUP"  /dev/$ssdVar

sgdisk -n 1:0:+"$winDataPartinMB"MiB -t 0:0700 -c 0:"DATA" /dev/$hddVar

sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar
pause


# Create filesystems
mkfs.vfat -F 32 /dev/"$ssdVar""p1" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$ssdVar""p3" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$ssdVar""p4" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$ssdVar""p5" >/dev/null 2>&1

mkfs.ntfs -Q /dev/"$hddVar""1" >/dev/null 2>&1



# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 
echo "Stvaram direktorije za Backup GPT struktura"
saveDIR=~/BACKUP
mkdir -p $saveDIR/SSD/CONF4/NASTAVNICKA
mkdir -p $saveDIR/HDD/CONF4/NASTAVNICKA

echo "Spremam GPT sa svim particijama na diskovima"
sgdisk --backup=$saveDIR/SSD/CONF4/KABINETI/00_SSD_ALLPARTITIONS.gpt /dev/"$ssdVar" >/dev/null 2>&1
dd if=$saveDIR/SSD/CONF4/NASTAVNICKA/00_SSD_ALLPARTITIONS.gpt bs=512 count=1 > $saveDIR/SSD/CONF4/NASTAVNICKA/01_SSD_protectiveMBR.gpt
dd if=$saveDIR/SSD/CONF4/NASTAVNICKA/00_SSD_ALLPARTITIONS.gpt bs=512 skip=1 count=1 > $saveDIR/SSD/CONF4/NASTAVNICKA/02_SSD_primaryHEADER.gpt
dd if=$saveDIR/SSD/CONF4/NASTAVNICKA/00_SSD_ALLPARTITIONS.gpt bs=512 skip=2 count=1 > $saveDIR/SSD/CONF4/NASTAVNICKA/03_SSD_backupHEADER.gpt
dd if=$saveDIR/SSD/CONF4/NASTAVNICKA/00_SSD_ALLPARTITIONS.gpt bs=512 skip=3 > $saveDIR/SSD/CONF4/NASTAVNICKA/04_SSD_GPTPartitions.gpt

sgdisk --backup=$saveDIR/HDD/CONF4/NASTAVNICKA/00_HDD_ALLPARTITIONS.gpt /dev/"$hddVar" >/dev/null 2>&1
dd if=$saveDIR/HDD/CONF4/NASTAVNICKA/00_HDD_ALLPARTITIONS.gpt bs=512 count=1 > $saveDIR/HDD/CONF4/NASTAVNICKA/01_HDD_protectiveMBR.gpt
dd if=$saveDIR/HDD/CONF4/NASTAVNICKA/00_HDD_ALLPARTITIONS.gpt bs=512 skip=1 count=1 > $saveDIR/HDD/CONF4/NASTAVNICKA/02_HDD_primaryHEADER.gpt
dd if=$saveDIR/HDD/CONF4/NASTAVNICKA/00_HDD_ALLPARTITIONS.gpt bs=512 skip=2 count=1 > $saveDIR/HDD/CONF4/NASTAVNICKA/03_HDD_backupHEADER.gpt
dd if=$saveDIR/HDD/CONF4/NASTAVNICKA/00_HDD_ALLPARTITIONS.gpt bs=512 skip=3 > $saveDIR/HDD/CONF4/NASTAVNICKA/04_HDD_GPTPartitions.gpt