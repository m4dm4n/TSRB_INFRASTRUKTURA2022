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
  then echo "Pokrenuti skriptu sa root ovlastima ( ./naziv_skripte.sh)"
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

#########
# Definiranje funkcije za provjeru broja particija
function syspartnumbercheck(){
  partprobe >/dev/null 2>&1
  sleep 2
  totalSysDrivePartitions=$(grep -c "$sysDrive"[0-9] /proc/partitions)
}

function datapartnumbercheck(){
  partprobe >/dev/null 2>&1
  sleep 2
  totalDataDrivePartitions=$(grep -c "$dataDrive""p"[0-9] /proc/partitions)
}

# Define SSD and HDD
#---------------------------
 fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

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

# Create folders
echo "Stvaram direktorije za Backup GPT struktura"
saveDIR=~/BACKUP
# Folders for Linux GPT backups
mkdir -p $saveDIR/$sysDrive/Linux{1,2}
# Folders for Windows GEN* backups
mkdir -p $saveDIR/$sysDrive/Windows10_GEN{1..5}
# Folders for Windows RAZNO backups
mkdir -p $saveDIR/$sysDrive/Windows10_RAZNO
# Folders for Windows SEM* backups
mkdir -p $saveDIR/$sysDrive/Windows10_SEM{1,2}
# Folders for Windows STORE backup - Only STORE
mkdir $saveDIR/$sysDrive/Windows10_STORE
# Folders for Windows STORE Linux* backups
mkdir -p $saveDIR/$sysDrive/Windows10_STORE_Linux{1..2}
# Folders for Windows STORE GEN* backups
mkdir -p $saveDIR/$sysDrive/Windows10_STORE_GEN{1..5}
# Folders for Windows STORE RAZNO backups
mkdir -p $saveDIR/$sysDrive/Windows10_STORE_RAZNO
# Folders for Windows STORE SEM* backups
mkdir -p $saveDIR/$sysDrive/Windows10_STORE_SEM{1,2}
# Folders for Windows STORE TEMP backups
mkdir $saveDIR/$sysDrive/Windows10_STORE_TEMP
# Folders for Linux DATA drive backups
mkdir -p $saveDIR/$dataDrive/Linux{1,2}
# Folders for Windows GEN* DATA drive backups
mkdir -p $saveDIR/$dataDrive/Windows10_GEN{1..5}
# Folders for Windows RAZNO DATA drive backups
mkdir -p $saveDIR/$dataDrive/Windows10_RAZNO
# Folders for Windows SEM* DATA drive backups
mkdir -p $saveDIR/$dataDrive/Windows10_SEM{1,2}
# Folders for Windows STORE DATA drive backup - Only STORE
mkdir $saveDIR/$dataDrive/Windows10_STORE


echo "Gotovo"

#########################################################################################################
#########################################################################################################
#### PARTITIONING
# Create GPT structure on drives
echo "Korak1"
echo "Stvaram GPT strukture na diskovima"
sgdisk  --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/$sysDrive >/dev/null 2>&1 
#########################################################################################################
#########################################################################################################




#########################################################################################################
#########################################################################################################
#### CREATE PARTITIONS ON HDD
# LINUX 1
echo "Korak2"
echo "Stvaram particije na sistemskom disku"
echo "Stvaram Linux1 particije"
sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"

# LINUX 2
echo "Stvaram Linux2 particije"
sgdisk -n 0:0:+"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"

# 1-5 GEN
echo "Stvaram GEN1-5 particije"
for (( i=1; i<=5; i++ ))
do
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"$i"" Generacija"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+50GiB -t 0:0700 -c 0:"GEN"$i" DATA"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Gotovo"

# RAZNO Windows10
echo "Stvaram RAZNO particije"
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Win10 RAZNO"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"

# 1-2 SEM
echo "Stvaram SEM1-2 particije"
for (( i=1; i<=2; i++ ))
do
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"SEM""$i" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"SEM"$i" DATA"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Gotovo"

# STORE Windows10
echo "Stvaram STORE particije"
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+50GiB -t 0:0700 -c 0:"STORE"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+1500GiB -t 0:0700 -c 0:"DATA"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"
#########################################################################################################
#########################################################################################################




#########################################################################################################
#########################################################################################################
#### CREATE PARTITIONS ON SSD
# LINUX 1
echo "Korak3"
echo "Stvaram Linux1 DATA particiju"
sgdisk -n 1:1MiB:20GiB -t 0:8300 -c 0:"Linux1 SSD" /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"

# LINUX 2
echo "Stvaram Linux2 DATA particiju"
sgdisk -n 0:0:+20GiB -t 0:8300 -c 0:"Linux2 SSD" /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"

# 1-5 GEN
echo "Stvaram GEN1-5 DATA particije"
for (( i=1; i<=5; i++ ))
do
sgdisk -n 0:0:+200GiB -t 0:0700 -c 0:"GEN"$i" Virtualke" /dev/$dataDrive >/dev/null 2>&1
done
echo "Gotovo"

# RAZNO Windows10
echo "Stvaram RAZNO DATA particiju"
sgdisk -n 0:0:+30GiB -t 0:0700 -c 0:"GENERAL Virtualke" /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"

# 1-2 SEM
echo "Stvaram SEM1-2 DATA particiju"
for (( i=1; i<=2; i++ ))
do
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"SEM"$i" Virtualke" /dev/$dataDrive >/dev/null 2>&1
done
echo "Gotovo"

# STORE Windows10
echo "Stvaram STORE DATA particiju"
sgdisk -n 0:0:+400GiB -t 0:0700 -c 0:"SSD Backup" /dev/$dataDrive >/dev/null 2>&1
echo "Gotovo"
#########################################################################################################
#########################################################################################################





#########################################################################################################
#########################################################################################################
### CREATE FILESYSTEMS
echo "Korak4"
echo "Stvaram datotecne sustave na particijama sistemskog diska"
# EFI FAT32 FILESYSTEM
echo "FAT32"
for s in $(sgdisk -p /dev/"$sysDrive" | grep EF00 | cut -d " " -f3,4);do mkfs.vfat -F 32 /dev/"$sysDrive""$s" >/dev/null 2>&1;done
# LINUX SWAP FILESYSTEM
echo "Linux SWAP"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8200 | cut -d " " -f3,4);do mkswap /dev/"$sysDrive""$s" >/dev/null 2>&1;done
# LINUX ROOT EXT4 FILESYSTEM
echo "ROOT EXT4"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8304 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$sysDrive""$s" >/dev/null 2>&1;done
# LINUX HOME EXT4 FILESYSTEM
echo "HOME EXT4"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8302 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$sysDrive""$s" >/dev/null 2>&1;done
# WINDOWS NTFS FILESYSTEM
echo "WIN NTFS"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$sysDrive""$s" >/dev/null 2>&1;done
# WINDOWS RECOVERY NTFS FILESYSTEM
echo "REC NTFS"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 2700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$sysDrive""$s" >/dev/null 2>&1;done
echo "Gotovo"

echo Korak5
# LINUX DATA EXT4 FILEYSTEM
echo "Stvaram datotecne sustave na particijama data diska"
for s in $(sgdisk -p /dev/"$dataDrive" | grep 8300 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$dataDrive"p"$s" >/dev/null 2>&1;done
# WINDOWS DATA NTFS FILESYSTEM
for s in $(sgdisk -p /dev/"$dataDrive" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$dataDrive"p"$s" >/dev/null 2>&1;done
echo "Gotovo"
#########################################################################################################
#########################################################################################################



#########################################################################################################
#########################################################################################################
# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 


# BACKUP FULL TABLES
echo "Korak6"
echo "Spremam GPT sa svim particijama na diskovima"
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
echo "Gotovo"


# COUNT TOTAL PARTITIONS
echo "Korak7"
echo "Pocetno prebrojavanje ukupnog broja particija"
syspartnumbercheck
datapartnumbercheck
echo "Gotovo"

# BACKUP ONLY LINUX1 GPT
echo "Korak8"
echo "Spremam Backup Linux1 GPT strukture"
syspartnumbercheck
for (( i=5; i<=totalSysDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
 sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
 sgdisk --backup=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt /dev/"$sysDrive"
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/01_SysDrive_Linux1_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/02_SysDrive_Linux1_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/04_SysDrive_Linux1_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/03_SysDrive_Linux1_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"


# BACKUP ONLY LINUX2 GPT
echo "Korak9"
echo "Spremam Backup Linux2 GPT strukture"
syspartnumbercheck
for (( i=9; i<=totalSysDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
for (( i=1; i<=4; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$sysDrive/Linux2/00_SysDrive_Linux2.gpt /dev/"$sysDrive"
dd if=$saveDIR/$sysDrive/Linux2/00_SysDrive_Linux2.gpt of=$saveDIR/$sysDrive/Linux2/01_SysDrive_Linux2_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux2/00_SysDrive_Linux2.gpt of=$saveDIR/$sysDrive/Linux2/02_SysDrive_Linux2_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux2/00_SysDrive_Linux2.gpt of=$saveDIR/$sysDrive/Linux2/04_SysDrive_Linux2_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux2/00_SysDrive_Linux2.gpt of=$saveDIR/$sysDrive/Linux2/03_SysDrive_Linux2_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"


# Saving Windows STORE partitions
echo "Korak10"
echo "Spremam Backup Store GPT strukture"
syspartnumbercheck
for (( i=1; i<=$((totalSysDrivePartitions-5)); i++ ))
do
	 sgdisk -d "$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt /dev/"$sysDrive" >/dev/null 2>&1
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/01_SysDrive_Windows10_STORE_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/02_SysDrive_Windows10_STORE_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/04_SysDrive_Windows10_STORE_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/03_SysDrive_Windows10_STORE_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"



# Saving Windows GEN1-5 Partitions
echo "Korak11"
echo "Spremam Backup GEN1-5 GPT strukture"
echo "Malo čišćenja"

#Brisanje Linux particija
for (( i=1; i<=8; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck

#Brisanje svega nakon GENx particija
for (( i=26; i<=totalSysDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"


echo "Spremanje Backup GEN1-5 GPT strukture"
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck

for (( i=1; i<=5; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
      for (( j=6; j<=totalSysDrivePartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$sysDrive" >/dev/null 2>&1
        done
  
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_GEN"$i"/00_SysDrive_Windows10_GEN"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$i"/00_SysDrive_Windows10_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$i"/01_SysDrive_Windows10_GEN"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$i"/00_SysDrive_Windows10_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$i"/02_SysDrive_Windows10_GEN"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$i"/00_SysDrive_Windows10_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$i"/04_SysDrive_Windows10_GEN"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$i"/00_SysDrive_Windows10_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$i"/03_SysDrive_Windows10_GEN"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1

    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    for (( n=6; n<=10; n++))
       do
         sgdisk -d "$n" /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$sysDrive" >/dev/null 2>&1

    syspartnumbercheck
 
if [ $var -eq 5 ]; then
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_GEN"$var"/00_SysDrive_Windows10_GEN"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$var"/00_SysDrive_Windows10_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$var"/01_SysDrive_Windows10_GEN"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$var"/00_SysDrive_Windows10_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$var"/02_SysDrive_Windows10_GEN"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$var"/00_SysDrive_Windows10_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$var"/04_SysDrive_Windows10_GEN"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_GEN"$var"/00_SysDrive_Windows10_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_GEN"$var"/03_SysDrive_Windows10_GEN"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi

done
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"




# Saving Windows RAZNO Partition
echo "Korak12"
echo "Spremam Backup RAZNO GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega prije RAZNO particija
syspartnumbercheck
for (( i=1; i<=33; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

#Brisanje svega nakon RAZNO particija
syspartnumbercheck
for (( i=6; i<=totalSysDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"

echo "Spremam Backup RAZNO GPT strukture"
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_RAZNO/00_SysDrive_Windows10_RAZNO.gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_RAZNO/00_SysDrive_Windows10_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_RAZNO/01_SysDrive_Windows10_RAZNO_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_RAZNO/00_SysDrive_Windows10_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_RAZNO/02_SysDrive_Windows10_RAZNO_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_RAZNO/00_SysDrive_Windows10_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_RAZNO/04_SysDrive_Windows10_RAZNO_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_RAZNO/00_SysDrive_Windows10_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_RAZNO/03_SysDrive_Windows10_RAZNO_GPTPartitions.gpt bs=512 skip=3 status=none

sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"




# Saving Windows SEM1-2 Partitions
echo "Korak13"
echo "Spremam Backup SEM1-2 GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega prije SEM1-2 particija
for (( i=1; i<=38; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

#Brisanje svega nakon SEM1-2 particija
syspartnumbercheck
for (( i=11; i<=totalSysDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"


echo "Spremam Backup SEM1-2 GPT strukture"
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck

for (( i=1; i<=2; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
      for (( j=6; j<=totalSysDrivePartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$sysDrive" >/dev/null 2>&1
        done
  
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_SEM"$i"/00_SysDrive_Windows10_SEM"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$i"/00_SysDrive_Windows10_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$i"/01_SysDrive_Windows10_SEM"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$i"/00_SysDrive_Windows10_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$i"/02_SysDrive_Windows10_SEM"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$i"/00_SysDrive_Windows10_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$i"/04_SysDrive_Windows10_SEM"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$i"/00_SysDrive_Windows10_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$i"/03_SysDrive_Windows10_SEM"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1

    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    for (( n=6; n<=10; n++))
       do
         sgdisk -d "$n" /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$sysDrive" >/dev/null 2>&1

    syspartnumbercheck

if [ $var -eq 2 ]; then
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_SEM"$var"/00_SysDrive_Windows10_SEM"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$var"/00_SysDrive_Windows10_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$var"/01_SysDrive_Windows10_SEM"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$var"/00_SysDrive_Windows10_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$var"/02_SysDrive_Windows10_SEM"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$var"/00_SysDrive_Windows10_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$var"/04_SysDrive_Windows10_SEM"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_SEM"$var"/00_SysDrive_Windows10_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_SEM"$var"/03_SysDrive_Windows10_SEM"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi
done
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"
#########################################################################################################
#########################################################################################################





#########################################################################################################
#########################################################################################################
###Saving STORE + SYSTEM partition packages

# Saving STORE+Linux1 Partitions
echo "Korak14"
echo "Spremam Backup STORE+Linux1 GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega između Linux1 i STORE particija
syspartnumbercheck
for (( i=5; i<=$((totalSysDrivePartitions-5)); i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Čišćenje gotovo"

# Need to be done manually, partition numbers not equal
echo "Spremanje Backup STORE+Linux1 GPT strukture"
sgdisk -r 1:5 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 2:6 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 3:7 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 4:8 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 8:9 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 7:8 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 6:7 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 5:6 /dev/"$sysDrive" >/dev/null 2>&1

sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_Linux1/00_SysDrive_Windows10_STORE_Linux1.gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux1/00_SysDrive_Windows10_STORE_Linux1.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux1/01_SysDrive_Windows10_STORE_Linux1_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux1/00_SysDrive_Windows10_STORE_Linux1.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux1/02_SysDrive_Windows10_STORE_Linux1_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux1/00_SysDrive_Windows10_STORE_Linux1.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux1/04_SysDrive_Windows10_STORE_Linux1_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux1/00_SysDrive_Windows10_STORE_Linux1.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux1/03_SysDrive_Windows10_STORE_Linux1_GPTPartitions.gpt bs=512 skip=3 status=none

sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"



# Saving STORE+Linux2 Partition
echo "Korak15"
echo "Spremam Backup STORE+Linux2 GPT strukture8"
echo "Malo čišćenja"

#Brisanje Svega prije Linux2 particija
syspartnumbercheck
for (( i=1; i<=4; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

#Brisanje svega između Linux2 i STORE particija
syspartnumbercheck
for (( i=5; i<=$((totalSysDrivePartitions-5)); i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"

# Need to be done manually, partition numbers not equal
echo "Spremanje Backup STORE+Linux2 GPT strukture8"
sgdisk -r 1:5 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 2:6 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 3:7 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 4:8 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 8:9 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 7:8 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 6:7 /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -r 5:6 /dev/"$sysDrive" >/dev/null 2>&1

sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_Linux2/00_SysDrive_Windows10_STORE_Linux2.gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux2/00_SysDrive_Windows10_STORE_Linux2.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux2/01_SysDrive_Windows10_STORE_Linux2_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux2/00_SysDrive_Windows10_STORE_Linux2.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux2/02_SysDrive_Windows10_STORE_Linux2_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux2/00_SysDrive_Windows10_STORE_Linux2.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux2/04_SysDrive_Windows10_STORE_Linux2_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_Linux2/00_SysDrive_Windows10_STORE_Linux2.gpt of=$saveDIR/$sysDrive/Windows10_STORE_Linux2/03_SysDrive_Windows10_STORE_Linux2_GPTPartitions.gpt bs=512 skip=3 status=none

sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"



# Saving STORE+ GEN1-5 Partitions
echo "Korak16"
echo "Spremam STORE+GEN1-5 GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega prije GENx particija
syspartnumbercheck
for (( i=1; i<=8; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1


#Brisanje svega između GENx i STORE particija
syspartnumbercheck
for (( i=26; i<=$((totalSysDrivePartitions-5)); i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"

echo "Spremanje Backup STORE GEN1-5 GPT strukture"
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck

for (( i=1; i<=5; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
      for (( j=6; j<=$((totalSysDrivePartitions-5)); j++ ))
        do
          sgdisk -d "$j" /dev/"$sysDrive" >/dev/null 2>&1
        done

    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1  
    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/00_SysDrive_Windows10_STORE_GEN"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/00_SysDrive_Windows10_STORE_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/01_SysDrive_Windows10_STORE_GEN"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/00_SysDrive_Windows10_STORE_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/02_SysDrive_Windows10_STORE_GEN"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/00_SysDrive_Windows10_STORE_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/04_SysDrive_Windows10_STORE_GEN"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/00_SysDrive_Windows10_STORE_GEN"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$i"/03_SysDrive_Windows10_STORE_GEN"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1

for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    for (( n=6; n<=10; n++))
       do
         sgdisk -d "$n" /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$sysDrive" >/dev/null 2>&1

    syspartnumbercheck

if [ $var -eq 5 ]; then
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/00_SysDrive_Windows10_STORE_GEN"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/00_SysDrive_Windows10_STORE_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/01_SysDrive_Windows10_STORE_GEN"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/00_SysDrive_Windows10_STORE_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/02_SysDrive_Windows10_STORE_GEN"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/00_SysDrive_Windows10_STORE_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/04_SysDrive_Windows10_STORE_GEN"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/00_SysDrive_Windows10_STORE_GEN"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_GEN"$var"/03_SysDrive_Windows10_STORE_GEN"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi

done
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"



# Saving STORE + RAZNO Partitions
echo "Korak17"
echo "Spremam STORE+RAZNO GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega prije RAZNO particija
syspartnumbercheck
for (( i=1; i<=33; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

#Brisanje svega između RAZNO i STORE particija
syspartnumbercheck
for (( i=6; i<=$((totalSysDrivePartitions-5)); i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"


echo "Spremanje STORE+RAZNO GPT strukture"
syspartnumbercheck  
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/00_SysDrive_Windows10_STORE_RAZNO.gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/00_SysDrive_Windows10_STORE_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/01_SysDrive_Windows10_STORE_RAZNO_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/00_SysDrive_Windows10_STORE_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/02_SysDrive_Windows10_STORE_RAZNO_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/00_SysDrive_Windows10_STORE_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/04_SysDrive_Windows10_STORE_RAZNO_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/00_SysDrive_Windows10_STORE_RAZNO.gpt of=$saveDIR/$sysDrive/Windows10_STORE_RAZNO/03_SysDrive_Windows10_STORE_RAZNO_GPTPartitions.gpt bs=512 skip=3 status=none

sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"





# Saving STORE + SEM1-2 Partitions
echo "Korak18"
echo "Spremam Backup STORE+SEM1-2 GPT strukture"
echo "Malo čišćenja"

#Brisanje Svega prije SEM1-2 particija
syspartnumbercheck
for (( i=1; i<=38; i++ ))
do
 sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Čišćenje gotovo"

echo "Spremanje Backup STORE+SEM1-2 GPT strukture"
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
for (( i=1; i<=2; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
      for (( j=6; j<=$((totalSysDrivePartitions-5)); j++ ))
        do
          sgdisk -d "$j" /dev/"$sysDrive" >/dev/null 2>&1
        done
    
    syspartnumbercheck
    
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/00_SysDrive_Windows10_STORE_SEM"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/00_SysDrive_Windows10_STORE_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/01_SysDrive_Windows10_STORE_SEM"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/00_SysDrive_Windows10_STORE_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/02_SysDrive_Windows10_STORE_SEM"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/00_SysDrive_Windows10_STORE_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/04_SysDrive_Windows10_STORE_SEM"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/00_SysDrive_Windows10_STORE_SEM"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$i"/03_SysDrive_Windows10_STORE_SEM"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1

for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
    
    for (( n=6; n<=10; n++))
       do
         sgdisk -d "$n" /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$sysDrive" >/dev/null 2>&1

    syspartnumbercheck
    
if [ $var -eq 2 ]; then
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
    for (( k=1; k<=5; k++ ))
       do
         sgdisk -r "$k":$((k+5)) /dev/"$sysDrive" >/dev/null 2>&1
       done
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/00_SysDrive_Windows10_STORE_SEM"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/00_SysDrive_Windows10_STORE_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/01_SysDrive_Windows10_STORE_SEM"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/00_SysDrive_Windows10_STORE_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/02_SysDrive_Windows10_STORE_SEM"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/00_SysDrive_Windows10_STORE_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/04_SysDrive_Windows10_STORE_SEM"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/00_SysDrive_Windows10_STORE_SEM"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_SEM"$var"/03_SysDrive_Windows10_STORE_SEM"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi

done
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
syspartnumbercheck
echo "Gotovo"
#########################################################################################################
#########################################################################################################



#########################################################################################################
#########################################################################################################
### Saving DATA partitions

# Saving Linux1-2 DATA drive Partitions
echo "Korak19"
echo "Spremam Backup Linux1-2 DATA drive GPT strukture"

datapartnumbercheck
for (( i=2; i<=totalDataDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done
 sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1
 sgdisk --backup=$saveDIR/$dataDrive/Linux1/00_DataDrive_Linux1.gpt /dev/"$dataDrive"
dd if=$saveDIR/$dataDrive/Linux1/00_DataDrive_Linux1.gpt of=$saveDIR/$dataDrive/Linux1/01_DataDrive_Linux1_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux1/00_DataDrive_Linux1.gpt of=$saveDIR/$dataDrive/Linux1/02_DataDrive_Linux1_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux1/00_DataDrive_Linux1.gpt of=$saveDIR/$dataDrive/Linux1/04_DataDrive_Linux1_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux1/00_DataDrive_Linux1.gpt of=$saveDIR/$dataDrive/Linux1/03_DataDrive_Linux1_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1

datapartnumbercheck
for (( i=3; i<=totalDataDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

sgdisk --delete=1 /dev/"$dataDrive" >/dev/null 2>&1

 sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1
 sgdisk --backup=$saveDIR/$dataDrive/Linux2/00_DataDrive_Linux2.gpt /dev/"$dataDrive"
dd if=$saveDIR/$dataDrive/Linux2/00_DataDrive_Linux2.gpt of=$saveDIR/$dataDrive/Linux2/01_DataDrive_Linux2_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux2/00_DataDrive_Linux2.gpt of=$saveDIR/$dataDrive/Linux2/02_DataDrive_Linux2_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux2/00_DataDrive_Linux2.gpt of=$saveDIR/$dataDrive/Linux2/04_DataDrive_Linux2_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$dataDrive/Linux2/00_DataDrive_Linux2.gpt of=$saveDIR/$dataDrive/Linux2/03_DataDrive_Linux2_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1

datapartnumbercheck
echo "Gotovo"



# Saving GEN1-5 DATA drive Partitions
echo "Korak20"
echo "Spremam Backup GEN1-5 DATA drive GPT strukture"
echo "Malo čišćenja"

#Brisanje Linux particija
datapartnumbercheck
for (( i=1; i<=2; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done
sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1

#Brisanje svega nakon GENx particija
datapartnumbercheck
for (( i=6; i<=totalDataDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done
echo "Čišćenje gotovo"

echo "Spremanje Backup GEN1-5 DATA drive GPT strukture"
sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_1.gpt /dev/"$dataDrive" >/dev/null 2>&1
datapartnumbercheck
for (( i=1; i<=5; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1
      for (( j=2; j<=totalDataDrivePartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$dataDrive" >/dev/null 2>&1
        done
  
    sgdisk --backup=$saveDIR/$dataDrive/Windows10_GEN"$i"/00_DataDrive_Windows10_GEN"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$i"/00_DataDrive_Windows10_GEN"$i".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$i"/01_DataDrive_Windows10_GEN"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$i"/00_DataDrive_Windows10_GEN"$i".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$i"/02_DataDrive_Windows10_GEN"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$i"/00_DataDrive_Windows10_GEN"$i".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$i"/04_DataDrive_Windows10_GEN"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$i"/00_DataDrive_Windows10_GEN"$i".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$i"/03_DataDrive_Windows10_GEN"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1

    sgdisk -d 1 /dev/"$dataDrive" >/dev/null 2>&1
    
    sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$dataDrive" >/dev/null 2>&1

    datapartnumbercheck
   
if [ $var -eq 5 ]; then
    sgdisk --backup=$saveDIR/$dataDrive/Windows10_GEN"$var"/00_DataDrive_Windows10_GEN"$var".gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$var"/00_DataDrive_Windows10_GEN"$var".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$var"/01_DataDrive_Windows10_GEN"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$var"/00_DataDrive_Windows10_GEN"$var".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$var"/02_DataDrive_Windows10_GEN"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$var"/00_DataDrive_Windows10_GEN"$var".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$var"/04_DataDrive_Windows10_GEN"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_GEN"$var"/00_DataDrive_Windows10_GEN"$var".gpt of=$saveDIR/$dataDrive/Windows10_GEN"$var"/03_DataDrive_Windows10_GEN"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi

done
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
datapartnumbercheck
echo "Gotovo"



# Saving RAZNO DATA drive Partitions
echo "Korak21"
echo "Spremam Backup RAZNO DATA drive GPT strukture"
datapartnumbercheck
for (( i=1; i<=7; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

for (( i=9; i<=totalDataDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

 sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$dataDrive/Windows10_RAZNO/00_DataDrive_Windows10_RAZNO.gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_RAZNO/00_DataDrive_Windows10_RAZNO.gpt of=$saveDIR/$dataDrive/Windows10_RAZNO/01_DataDrive_Windows10_RAZNO_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_RAZNO/00_DataDrive_Windows10_RAZNO.gpt of=$saveDIR/$dataDrive/Windows10_RAZNO/02_DataDrive_Windows10_RAZNO_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_RAZNO/00_DataDrive_Windows10_RAZNO.gpt of=$saveDIR/$dataDrive/Windows10_RAZNO/04_DataDrive_Windows10_RAZNO_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_RAZNO/00_DataDrive_Windows10_RAZNO.gpt of=$saveDIR/$dataDrive/Windows10_RAZNO/03_DataDrive_Windows10_RAZNO_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1

datapartnumbercheck
echo "Gotovo"


# Saving SEM1-2 DATA drive Partitions
echo "Korak22"
echo "Spremam Backup SEM1-2 DATA drive GPT strukture"

for (( i=1; i<=$(( totalDataDrivePartitions - 3 )); i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

for (( i=$(( totalDataDrivePartitions - 2 )); i<=$totalDataDrivePartitions; i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1

sgdisk --backup=$saveDIR/$dataDrive/Windows10_SEM1/00_DataDrive_Windows10_SEM1.gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_SEM1/00_DataDrive_Windows10_SEM1.gpt of=$saveDIR/$dataDrive/Windows10_SEM1/01_DataDrive_Windows10_SEM1_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM1/00_DataDrive_Windows10_SEM1.gpt of=$saveDIR/$dataDrive/Windows10_SEM1/02_DataDrive_Windows10_SEM1_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM1/00_DataDrive_Windows10_SEM1.gpt of=$saveDIR/$dataDrive/Windows10_SEM1/04_DataDrive_Windows10_SEM1_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM1/00_DataDrive_Windows10_SEM1.gpt of=$saveDIR/$dataDrive/Windows10_SEM1/03_DataDrive_Windows10_SEM1_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
datapartnumbercheck

for (( i=1; i<=$(( totalDataDrivePartitions - 2 )); i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

sgdisk --delete="$totalDataDrivePartitions" /dev/"$dataDrive" >/dev/null 2>&1

sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1

sgdisk --backup=$saveDIR/$dataDrive/Windows10_SEM2/00_DataDrive_Windows10_SEM2.gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_SEM2/00_DataDrive_Windows10_SEM2.gpt of=$saveDIR/$dataDrive/Windows10_SEM2/01_DataDrive_Windows10_SEM2_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM2/00_DataDrive_Windows10_SEM2.gpt of=$saveDIR/$dataDrive/Windows10_SEM2/02_DataDrive_Windows10_SEM2_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM2/00_DataDrive_Windows10_SEM2.gpt of=$saveDIR/$dataDrive/Windows10_SEM2/04_DataDrive_Windows10_SEM2_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_SEM2/00_DataDrive_Windows10_SEM2.gpt of=$saveDIR/$dataDrive/Windows10_SEM2/03_DataDrive_Windows10_SEM2_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
datapartnumbercheck
echo "Gotovo"

echo Korak23
# Saving STORE DATA drive Partitions
echo "Spremam Backup STORE DATA drive GPT strukture"
datapartnumbercheck
for (( i=1; i<=$(( totalDataDrivePartitions - 1 )); i++ ))
do
 sgdisk --delete="$i" /dev/"$dataDrive" >/dev/null 2>&1
done

 sgdisk --sort /dev/"$dataDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$dataDrive/Windows10_STORE/00_DataDrive_Windows10_STORE.gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_STORE/00_DataDrive_Windows10_STORE.gpt of=$saveDIR/$dataDrive/Windows10_STORE/01_DataDrive_Windows10_STORE_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_STORE/00_DataDrive_Windows10_STORE.gpt of=$saveDIR/$dataDrive/Windows10_STORE/02_DataDrive_Windows10_STORE_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_STORE/00_DataDrive_Windows10_STORE.gpt of=$saveDIR/$dataDrive/Windows10_STORE/04_DataDrive_Windows10_STORE_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_STORE/00_DataDrive_Windows10_STORE.gpt of=$saveDIR/$dataDrive/Windows10_STORE/03_DataDrive_Windows10_STORE_GPTPartitions.gpt bs=512 skip=3 status=none
sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1

datapartnumbercheck
echo "Gotovo"
#########################################################################################################
#########################################################################################################



##<<'###BLOCK-COMMENT'
###BLOCK-COMMENT
