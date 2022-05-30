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

# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#---------------------------

# Create folders for backup
echo "Stvaram direktorije za Backup GPT struktura"
saveDIR=~/BACKUP
mkdir -p $saveDIR/$sysDrive/SINGLE
mkdir -p $saveDIR/$dataDrive/SINGLE


# Calculate Windows System partition size
winBackupPartinMB=30000
winSystemPartinMB=$(( TotalFreeInMBytesSysDrive - winEfiPartinMB - msrPartinMB - winRecoveryPartinMB - winBackupPartinMB - 2 ))
winSystemPartinGB=$(( winSystemPartinMB / 1024 ))
echo "Velicina Windows Sistemske Particije: " $winSystemPartinGB "GB"
echo -e "\n"
winDataPartinMB=$(( TotalFreeinMBDataDrive - 2 ))

# Create GPT structure on drives
echo "Stvaram GPT strukturu na diskovima..."
sgdisk --mbrtogpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"

# Create Windows partitions
echo "Stvaram particije na Sistemskom disku..."
sgdisk -n 1:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 2:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 3:0:+"$winSystemPartinMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 4:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 5:0:+"$winBackupPartinMB"MiB -t 0:0700 -c 0:"BACKUP"  /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"

# Create HDD partition
echo "Stvaram particije na Data disku"
sgdisk -n 1:0:+"$winDataPartinMB"MiB -t 0:0700 -c 0:"DATA" /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"

# Create filesystems
echo "Stvaram datotečne sustave na diskovima"
mkfs.vfat -F 32 /dev/"$sysDrive""p1" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""p3" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""p4" >/dev/null 2>&1
mkfs.ntfs -Q /dev/"$sysDrive""p5" >/dev/null 2>&1

mkfs.ntfs -Q /dev/"$dataDrive""1" >/dev/null 2>&1

echo "Ispisujem informacije o datotečnim sustavima na particijama"
lsblk -o name,fstype,size,partuuid
echo
echo

echo "Ispisujem GPT tablice"
sgdisk -p /dev/$sysDrive
sgdisk -p /dev/$dataDrive
pause

# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 
echo "Stvaram direktorije za Backup GPT struktura"
mkdir -p $saveDIR/$sysDrive/SINGLE
mkdir -p $saveDIR/$dataDrive/SINGLE

echo "Spremam GPT sa svim particijama na diskovima"
sgdisk --backup=$saveDIR/$sysDrive/SINGLE/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
dd if=$saveDIR/$sysDrive/SINGLE/00_SysDrive_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/SINGLE/01_SysDrive_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/SINGLE/00_SysDrive_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/SINGLE/02_SysDrive_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/SINGLE/00_SysDrive_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/SINGLE/03_SysDrive_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/SINGLE/00_SysDrive_ALLPARTITIONS.gpt of=$saveDIR/$sysDrive/SINGLE/04_SysDrive_GPTPartitions.gpt bs=512 skip=3 status=none

sgdisk --backup=$saveDIR/$dataDrive/SINGLE/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
dd if=$saveDIR/$dataDrive/SINGLE/00_DataDrive_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/SINGLE/01_DataDrive_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$dataDrive/SINGLE/00_DataDrive_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/SINGLE/02_DataDrive_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$dataDrive/SINGLE/00_DataDrive_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/SINGLE/03_DataDrive_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$dataDrive/SINGLE/00_DataDrive_ALLPARTITIONS.gpt of=$saveDIR/$dataDrive/SINGLE/04_DataDrive_GPTPartitions.gpt status=none