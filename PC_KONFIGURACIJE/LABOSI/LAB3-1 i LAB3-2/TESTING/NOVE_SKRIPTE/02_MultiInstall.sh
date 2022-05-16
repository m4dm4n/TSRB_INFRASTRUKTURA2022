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
  then echo "Pokrenuti skriptu sa root ovlastima (Primjer: sudo ./naziv_skripte.sh)"
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

# Create folders
echo "Stvaram direktorije za Backup GPT struktura"
mkdir -p $saveDIR/$dataDrive
mkdir -p $saveDIR/$sysDrive/Linux1

for (( i=1; i<=$(( numberOfWinInstalls + 1 )); i++ ))
do
mkdir $saveDIR/$dataDrive/Windows10_"$i"
done

for (( i=1; i<=numberOfWinInstalls; i++ ))
do
mkdir $saveDIR/$sysDrive/Windows10_"$i"
done

for (( i=1; i<=numberOfWinInstalls; i++ ))
do
mkdir $saveDIR/$sysDrive/Windows10_STORE_"$i"
done

mkdir $saveDIR/$sysDrive/Windows10_STORE_TEMP
echo "Gotovo"



# PARTITIONING

# Create GPT structure on drives
echo "Stvaram GPT strukturu na diskovima"
sgdisk  --mbrtogpt /dev/"$sysDrive" >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/"$dataDrive" >/dev/null 2>&1
echo "Gotovo"

# Create Linux HOME partition on System Drive
if [ $linuxHomeNeeded -eq 1 ]
then
echo "Stvaram Linux Home particije"
sgdisk -n 1:2048:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 3:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 4:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"
fi
# Create Windows partitions on System Drive
echo "Stvaram Windows particije"
for (( i=1; i<=numberOfWinInstalls; i++ ))
do
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$winSystemPartSizeGB"GiB -t 0:0700 -c 0:"Windows11"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1
done
echo "Gotovo"

# Create BACKUP partition on System Drive
echo "Stvaram BACKUP particiju"

# ReCalculate System Drive free space, we need latest value
TotalFreeInMBytesSysDrive=$(( $( sgdisk -p /dev/"$sysDrive" | grep 'Total free space' | cut -d " " -f 5) * 512 / 1024 / 1024 ))

# Calculate winBACKUP OS size
winBACKUPinMB=$(( TotalFreeInMBytesSysDrive - winEfiPartinMB - msrPartinMB - winRecoveryPartinMB - 2 ))

sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$winBACKUPinMB"MiB -t 0:0700 -c 0:"STORE"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"

partprobe
sync
echo "5 sekundi čekanja za cache dump"
sleep 5

# Create winSystem DATA and BACKUP partitions on Data Drive
clear

echo "Stvaram  winSystem DATA particije"
for (( i=1; i<=numberOfWinInstalls; i++ ))
do
sgdisk -n $i:0:+"$dataPartSizeGB"GiB -t 0:0700 -c 0:"DATA$i"  /dev/"$dataDrive" >/dev/null 2>&1
done

sgdisk -n 0:0:+"$requiredSTOREspaceGB"GiB -t 0:0700 -c 0:"STORE"  /dev/"$dataDrive" >/dev/null 2>&1

partprobe
sync
echo "5 sekundi čekanja za cache dump"
sleep 5

# Done , print GPT structures
#echo "Ispis GPT struktura"
#sgdisk -p /dev/"$sysDrive"
#sgdisk -p /dev/"$dataDrive"


# PUT HIDDEN ATTRIBUTE ON MS RECOVERY PARTITIONS 
# JE LI OVO STVARNO POTREBNO???
#for s in $(sgdisk -p /dev/"$sysDrive" | grep 2700 | cut -d " " -f3,4);do sgdisk --attributes="$s":set:0:2 /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done


### CREATE FILESYSTEMS
echo "Stvaram datotecne sustave na particijama"
# EFI FAT32 FILESYSTEM
echo "FAT32"
for s in $(sgdisk -p /dev/"$sysDrive" | grep EF00 | cut -d " " -f3,4);do mkfs.vfat -F 32 /dev/"$sysDrive"p"$s" ;done
# LINUX SWAP FILESYSTEM
echo "Linux SWAP"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8200 | cut -d " " -f3,4);do mkswap /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done
# LINUX ROOT EXT4 FILESYSTEM
echo "ROOT EXT4"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8304 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done
# LINUX HOME EXT4 FILESYSTEM
echo "HOME EXT4"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 8302 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done
# WINDOWS NTFS FILESYSTEM
echo "WIN NTFS"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done
# WINDOWS RECOVERY NTFS FILESYSTEM
echo "REC NTFS"
for s in $(sgdisk -p /dev/"$sysDrive" | grep 2700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$sysDrive"p"$s" >/dev/null 2>&1;done

# WINDOWS DATA NTFS FILESYSTEM
for s in $(sgdisk -p /dev/"$dataDrive" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$dataDrive""$s" >/dev/null 2>&1;done
echo "Gotovo"



# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 

# BACKUP FULL TABLES
echo "Spremam GPT sa svim particijama na diskovima"
sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
echo "Gotovo"

# COUNT TOTAL PARTITIONS
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
totalDataDrivePartitions=$(grep -c "$dataDrive"[0-9] /proc/partitions)

# BACKUP ONLY LINUX GPT
echo "Spremam Backup Linux GPT strukture"
for (( i=5; i<=totalSysDrivePartitions; i++ ))
do
sudo sgdisk --delete="$i" /dev/"$sysDrive" >/dev/null 2>&1
done
sudo sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
sudo sgdisk --backup=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt /dev/"$sysDrive"
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/01_SysDrive_Linux1_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/02_SysDrive_Linux1_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/04_SysDrive_Linux1_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/Linux1/00_SysDrive_Linux1.gpt of=$saveDIR/$sysDrive/Linux1/03_SysDrive_Linux1_GPTPartitions.gpt bs=512 skip=3 status=none
echo "Gotovo"

# RESTORE BACKUP GPT WITH ALL PARTITIONS
sudo sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
sudo sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_ALLPARTITIONS.gpt /dev/"$dataDrive" >/dev/null 2>&1

# Saving Windows STORE partitions
echo "Spremam Backup Store GPT strukture"
mkdir $saveDIR/$sysDrive/Windows10_STORE
for (( i=1; i<=$((totalSysDrivePartitions-4)); i++ ))
     do
	 sgdisk -d "$i" /dev/"$sysDrive" >/dev/null 2>&1
	 done
sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt /dev/"$sysDrive" >/dev/null 2>&1
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/01_SysDrive_Windows10_STORE_protectiveMBR.gpt bs=512 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/02_SysDrive_Windows10_STORE_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/04_SysDrive_Windows10_STORE_backupHEADER.gpt bs=512 skip=2 count=1 status=none
dd if=$saveDIR/$sysDrive/Windows10_STORE/00_SysDrive_Windows10_STORE.gpt of=$saveDIR/$sysDrive/Windows10_STORE/03_SysDrive_Windows10_STORE_GPTPartitions.gpt bs=512 skip=3 status=none
echo "Gotovo"

# BACKUP WINDOWS GPT STRUCTURES
# A little bit of cleaning first, removing Linux and Store partitions
echo "Malo ciscenja..."
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
totalDataDrivePartitions=$(grep -c "$dataDrive"[0-9] /proc/partitions)

for (( i=1; i<=4; i++ ))
     do
       sgdisk -d "$i" /dev/"$sysDrive" >/dev/null 2>&1
     done
for (( i=totalSysDrivePartitions; i>$((totalSysDrivePartitions-4)); i-- ))
     do
       sgdisk -d $i /dev/"$sysDrive" >/dev/null 2>&1
     done
sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1

# New partition number calculating
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
totalDataDrivePartitions=$(grep -c "$dataDrive"[0-9] /proc/partitions)
echo "Ukupno ima ""$totalSysDrivePartitions"" Particija"

# Saving Windows partitions

echo "Spremam Backup Windows GPT strukture"
for (( i=1; i<=numberOfWinInstalls; i++ ))
    do
      sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
      for (( j=5; j<=totalSysDrivePartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$sysDrive" >/dev/null 2>&1
        done
  
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt of=$saveDIR/$sysDrive/Windows10_"$i"/01_SysDrive_Windows10_"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt of=$saveDIR/$sysDrive/Windows10_"$i"/02_SysDrive_Windows10_"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt of=$saveDIR/$sysDrive/Windows10_"$i"/04_SysDrive_Windows10_"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt of=$saveDIR/$sysDrive/Windows10_"$i"/03_SysDrive_Windows10_"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1

    for (( k=1; k<=4; k++ ))
       do
         sgdisk -r "$k":$((k+4)) /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    for (( n=5; n<=8; n++))
       do
         sgdisk -d "$n" /dev/"$sysDrive" >/dev/null 2>&1
       done
 
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$sysDrive/00_SysDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$sysDrive" >/dev/null 2>&1

    totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
    echo "Ukupan broj SysDrive particija: "$totalSysDrivePartitions

if [ $var -eq $numberOfWinInstalls ]; then
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_"$var"/00_SysDrive_Windows10_"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_"$var"/00_SysDrive_Windows10_"$var".gpt of=$saveDIR/$sysDrive/Windows10_"$var"/01_SysDrive_Windows10_"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$var"/00_SysDrive_Windows10_"$var".gpt of=$saveDIR/$sysDrive/Windows10_"$var"/02_SysDrive_Windows10_"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$var"/00_SysDrive_Windows10_"$var".gpt of=$saveDIR/$sysDrive/Windows10_"$var"/04_SysDrive_Windows10_"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_"$var"/00_SysDrive_Windows10_"$var".gpt of=$saveDIR/$sysDrive/Windows10_"$var"/03_SysDrive_Windows10_"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
  break 
fi

done
echo "Gotovo"


# Saving STORE partitions populated with different Windows installations (for Backup purposes)
echo "Spremam pakete Store GPT strukture sa Windows sustavima (za backup OS-ova)"

# Restore full GPT
sgdisk --load-backup=$saveDIR/$sysDrive/00_SysDrive_ALLPARTITIONS.gpt /dev/"$sysDrive" >/dev/null 2>&1

# Recalculate partitions 
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
totalDataDrivePartitions=$(grep -c "$dataDrive"[0-9] /proc/partitions)

# Delete  Linux partitions
echo "Brisem Linux particije"

for (( i=1; i<=4; i++ ))
do
    sgdisk -d "$i" /dev/$sysDrive >/dev/null 2>&1
done
    sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
echo "Gotovo"

# Backup Cleaned GPT structure
sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_1.gpt /dev/"$sysDrive" >/dev/null 2>&1

# Saving STORE partition packages
echo "Spremam PAKETE WindowsStore particija"
for (( i=1; i<=numberOfWinInstalls; i++ ))
    do
#      echo "$i"" Prolaz"
      sgdisk --load-backup=$saveDIR/$sysDrive/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
#    clear    
#    echo "Ispis prije brisanja tablica "$i
#    sgdisk -p /dev/"$sysDrive"
#    pause
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
for (( j=5; j<=$((totalSysDrivePartitions-4)); j++ ))
        do
          sgdisk -d $j /dev/"$sysDrive" >/dev/null 2>&1
        done
#    clear    
#    echo "Ispis nakon brisanja tablica "$i
#    sgdisk -p /dev/"$sysDrive"
#    pause
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1

    for (( k=1; k<=4; k++ ))
       do
         sgdisk -r $k:$(($k+4)) /dev/"$sysDrive" >/dev/null 2>&1
       done
    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$i"/01_SysDrive_Windows10_STORE_"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$i"/02_SysDrive_Windows10_STORE_"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$i"/04_SysDrive_Windows10_STORE_"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$i"/03_SysDrive_Windows10_STORE_"$i"_GPTPartitions.gpt bs=512 skip=3 status=none


sgdisk --load-backup=$saveDIR/$sysDrive/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1
for (( j=1; j<=4; j++ ))
        do
          sgdisk -d $j /dev/"$sysDrive" >/dev/null 2>&1
        done 
  
    sgdisk --sort /dev/"$sysDrive" >/dev/null 2>&1
    var=$(( $i + 1 ))

    totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
    partprobe /dev/"$sysDrive"
if [ $var -eq $numberOfWinInstalls ]; then

    for (( k=1; k<=4; k++ ))
       do
         sgdisk -r $k:$(($k+4)) /dev/"$sysDrive" >/dev/null 2>&1
       done

    sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_"$var"/00_SysDrive_Windows10_STORE_"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$var"/00_SysDrive_Windows10_STORE_"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$var"/01_SysDrive_Windows10_STORE_"$var"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$var"/00_SysDrive_Windows10_STORE_"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$var"/02_SysDrive_Windows10_STORE_"$var"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$var"/00_SysDrive_Windows10_STORE_"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$var"/04_SysDrive_Windows10_STORE_"$var"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$sysDrive/Windows10_STORE_"$var"/00_SysDrive_Windows10_STORE_"$var".gpt of=$saveDIR/$sysDrive/Windows10_STORE_"$var"/03_SysDrive_Windows10_STORE_"$var"_GPTPartitions.gpt bs=512 skip=3 status=none
break
fi
   sgdisk --backup=$saveDIR/$sysDrive/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$var".gpt /dev/"$sysDrive" >/dev/null 2>&1
totalSysDrivePartitions=$(grep -c "$sysDrive""p"[0-9] /proc/partitions)
done

echo "Gotovo"
echo "Ispisujem spremljene Store/Windows Backup GPT strukture"
for (( i=1; i<=numberOfWinInstalls; i++ ))
do
sgdisk -l $saveDIR/$sysDrive/Windows10_STORE_"$i"/00_SysDrive_Windows10_STORE_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1; sudo sgdisk -p /dev/"$sysDrive"
done


# Saving HDD DATA partitions 
totalDataDrivePartitions=$(grep -c "$dataDrive"[0-9] /proc/partitions)
echo "Spremam HDD DATA i STORE GPT strukture"
sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_1.gpt /dev/"$dataDrive"

for (( i=1; i<=$(( numberOfWinInstalls+1 )); i++ ))
    do
      sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1
      for (( j=2; j<=totalDataDrivePartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$dataDrive" >/dev/null 2>&1
        done
    sgdisk --backup=$saveDIR/$dataDrive/Windows10_"$i"/00_DataDrive_Windows10_"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1
    dd if=$saveDIR/$dataDrive/Windows10_"$i"/00_DataDrive_Windows10_"$i".gpt of=$saveDIR/$dataDrive/Windows10_"$i"/01_DataDrive_Windows10_"$i"_protectiveMBR.gpt bs=512 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_"$i"/00_DataDrive_Windows10_"$i".gpt of=$saveDIR/$dataDrive/Windows10_"$i"/02_DataDrive_Windows10_"$i"_primaryHEADER.gpt bs=512 skip=1 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_"$i"/00_DataDrive_Windows10_"$i".gpt of=$saveDIR/$dataDrive/Windows10_"$i"/04_DataDrive_Windows10_"$i"_backupHEADER.gpt bs=512 skip=2 count=1 status=none
    dd if=$saveDIR/$dataDrive/Windows10_"$i"/00_DataDrive_Windows10_"$i".gpt of=$saveDIR/$dataDrive/Windows10_"$i"/03_DataDrive_Windows10_"$i"_GPTPartitions.gpt bs=512 skip=3 status=none

    sgdisk --load-backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_"$i".gpt /dev/"$dataDrive" >/dev/null 2>&1

    sgdisk -r 1:$((i+1)) /dev/"$dataDrive" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/$dataDrive/00_DataDrive_CLEANED_PARTITIONS_$var.gpt /dev/"$dataDrive" >/dev/null 2>&1
done
echo "Gotovo"




#### PRINT BACKED UP TABLES
#echo "Ispisujem spremljene Windows Backup GPT strukture"
#for (( i=1; i<=numberOfWinInstalls; i++ ))
#do
#sgdisk -l $saveDIR/$sysDrive/Windows10_"$i"/00_SysDrive_Windows10_"$i".gpt /dev/"$sysDrive" >/dev/null 2>&1; sudo sgdisk -p /dev/"$sysDrive"
#done