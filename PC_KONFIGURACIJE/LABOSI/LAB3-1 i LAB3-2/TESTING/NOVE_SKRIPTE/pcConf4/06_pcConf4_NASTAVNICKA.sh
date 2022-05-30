#!/bin/bash

clear
##########
# Set some options
set -o errexit # It will exit on first error in script
set -o pipefail # It will exit on first error in some pipeline
##########

##########
# Provjera je li skripta pokrenuta sa root ovlastima
if [ "$EUID" -ne 0 ]
  then echo "Pokrenuti skriptu sa root ovlastima (sudo ./naziv_skripte.sh)"
  exit 1
fi
#########

#########
# Predefinirane veličine particija
# Linux particije
linEfiPartinMB=500
linSwapinGB=8
linRootinGB=50
linHomeinGB=10
# Windows particije
winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( winRecoveryPartinMB / 1024 ))


#########
# Definiranje pause funkcije
function pause(){
 read -s -n 1 -p "Pritisni bilo koju tipku za nastavak . . ."
 echo ""
}
#########


# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -n 3 -p $'Select System Drive(for OS): \n' sysDrive
echo -e "\n"
read -n 7 -p $'Select Data Drive(for VMs): \n' dataDrive
echo -e "\n"

TotalSizeinBSysDrive=$(fdisk -l | grep sda | cut -d " " -f5)
TotalSizeinMBSysDrive=$(( TotalSizeinBSysDrive / 1024 / 1024 ))
TotalSizeinGBSysDrive=$(( TotalSizeinBSysDrive / 1024 / 1024 / 1024 ))

TotalSizeinBDataDrive=$(fdisk -l | grep nvme | cut -d " " -f5)
TotalSizeinMBDataDrive=$(( TotalSizeinBDataDrive / 1024 / 1024 ))
TotalSizeinGBDataDrive=$(( TotalSizeinBDataDrive / 1024 / 1024 / 1024 ))

# Calculate Windows System partition size

winBackupPartinMB=50000
winSystemPartinMB=$(($TotalSizeinMBSysDrive-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-$winBackupPartinMB-2))
echo "Windows System Partition size is: " $(( $winSystemPartinMB / 1024 )) "GB"
echo
echo
winDataPartinMB=$(($TotalSizeinMBDataDrive-2))

echo Korak1
sgdisk --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --mbrtogpt /dev/$sysDrive >/dev/null 2>&1

echo Korak2
sgdisk -n 1:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 2:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 3:0:+"$winSystemPartinMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 4:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 5:0:+"$winBackupPartinMB"MiB -t 0:0700 -c 0:"BACKUP"  /dev/$sysDrive >/dev/null 2>&1

echo Korak3
sgdisk -n 1:0:+"$winDataPartinMB"MiB -t 0:0700 -c 0:"DATA" /dev/$dataDrive >/dev/null 2>&1

sgdisk -p /dev/$sysDrive
sgdisk -p /dev/$dataDrive
pause

echo Korak4
# Create filesystems
mkfs.vfat -F 32 /dev/"$sysDrive""1" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""3" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""4" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""5" >/dev/null 2>&1

mkfs.ntfs -Q /dev/"$dataDrive""p1" >/dev/null 2>&1


echo Korak5
# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 
echo "Stvaram direktorije za Backup GPT struktura"
saveDIR=~/BACKUP

mkdir -p $saveDIR/$sysDrive/CONF4/NASTAVNICKA
mkdir -p $saveDIR/$dataDrive/CONF4/NASTAVNICKA

echo "Spremam GPT sa svim particijama na diskovima"


sgdisk --backup=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/00_"$sysDrive"_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
dd if=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/00_"$sysDrive"_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/01_"$sysDrive"_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/00_"$sysDrive"_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/02_"$sysDrive"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/00_"$sysDrive"_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/03_"$sysDrive"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/00_"$sysDrive"_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/CONF4/NASTAVNICKA/04_"$sysDrive"_GPTPartitions.gpt status=none

sgdisk --backup=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/00_"$dataDrive"_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
dd if=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/00_"$dataDrive"_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/01_"$dataDrive"_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/00_"$dataDrive"_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/02_"$dataDrive"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/00_"$dataDrive"_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/03_"$dataDrive"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/00_"$dataDrive"_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/CONF4/NASTAVNICKA/04_"$dataDrive"_GPTPartitions.gpt bs=512 skip=3 status=none
