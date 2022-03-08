#!/bin/bash

# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}
#---------------------------


# Define some variables here
#---------------------------
clear
echo "Skripta za particioniranje ucenickih racunala, konfiguracija 1"
echo "Broj Windows instalacija: " "$numberofWininstalls"
echo "Veličina Windows sistemske particije: " "$winSystemPartSizeGB"
echo "Veličina DATA particije: " "$dataPartsizeGB"
pause


# Calculating disk sizes
nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(( nvmeSizeinB / 1024 / 1024 ))
nvmeSizeinGB=$(( nvmeSizeinB / 1024 / 1024 / 1024 ))
hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
hddSizeinMB=$(( hddSizeinB / 1024 / 1024 ))
hddSizeinGB=$(( hddSizeinB / 1024 / 1024 / 1024 ))

# Linux UEFI/GPT partition sizes
linEfiPartinMB=500
linSwapinGB=16
linRootinGB=50
linHomeinGB=30

# Windows UEFI/GPT partition sizes
winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( winRecoveryPartinMB / 1024 ))
#---------------------------


# Define SSD and HDD
#---------------------------
#sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'
#read -e -n 7 -p $'Select SSD: \n' ssdVar
#echo -e "\n"
#read -e -n 3 -p $'Select HDD: \n' hddVar
#echo -e "\n"
#---------------------------


# PARTITIONING

# Create GPT structure on drives
echo "Stvaram GPT strukturu na diskovima"
sgdisk  --mbrtogpt /dev/"$ssdVar" >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/"$hddVar" >/dev/null 2>&1
echo "Gotovo"

# SSD Create Linux HOME partition
if [ $linuxHomeNeeded -eq 1 ]
then
echo "Stvaram Linux Home particije"
sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 3:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 4:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/"$ssdVar" >/dev/null 2>&1
echo "Gotovo"
fi
# SSD Create Windows partitions
echo "Stvaram Windows particije"
for (( i=1; i<=numberofWininstalls; i++ ))
do
sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$winSystemPartSizeGB"GiB -t 0:0700 -c 0:"Windows11"  /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$ssdVar" >/dev/null 2>&1
done
echo "Gotovo"

# SSD Create BACKUP partition
echo "Stvaram BACKUP particiju"
TotalFreeSectorsNVME=$(sgdisk -p /dev/"$ssdVar" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$(( TotalFreeSectorsNVME * 512 ))
TotalFreeinMBNVME=$(( TotalFreeinBNVME / 1024 / 1024 ))
TotalFreeinGBNVME=$(( TotalFreeinMBNVME /1024 ))
winBACKUPinMB=$(( TotalFreeinMBNVME - winEfiPartinMB - msrPartinMB - winRecoveryPartinMB - 2 ))

sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$winBACKUPinMB"MiB -t 0:0700 -c 0:"STORE"  /dev/"$ssdVar" >/dev/null 2>&1
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$ssdVar" >/dev/null 2>&1
echo "Gotovo"


# HDD Create winSystem DATA and BACKUP partitions
clear
echo "Stvaram  winSystem DATA particije"
for (( i=1; i<=numberofWininstalls; i++ ))
do
echo "$i prolaz"
sgdisk -n $i:0:+"$dataPartsizeGB"GiB -t 0:0700 -c 0:"DATA$i"  /dev/"$hddVar" >/dev/null 2>&1
sgdisk -p /dev/sda
done

sgdisk -n 0:0:+"$requiredSTOREspaceGB"GiB -t 0:0700 -c 0:"STORE"  /dev/"$hddVar" >/dev/null 2>&1


# Done , print GPT structures
echo "Ispis GPT struktura"
sgdisk -p /dev/"$ssdVar"
sgdisk -p /dev/"$hddVar"

pause


# PUT HIDDEN ATTRIBUTE ON MS RECOVERY PARTITIONS 
# JE LI OVO STVARNO POTREBNO???
#for s in $(sgdisk -p /dev/"$ssdVar" | grep 2700 | cut -d " " -f3,4);do sgdisk --attributes="$s":set:0:2 /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done

### CREATE FILESYSTEMS
echo "Stvaram datotecne sustave na particijama"
# EFI FAT32 FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep EF00 | cut -d " " -f3,4);do mkfs.vfat -F 32 /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done
# LINUX SWAP FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep 8200 | cut -d " " -f3,4);do mkswap /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done
# LINUX ROOT EXT4 FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep 8304 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done
# LINUX HOME EXT4 FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep 8302 | cut -d " " -f3,4);do mkfs.ext4 /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done
# WINDOWS NTFS FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done
# WINDOWS RECOVERY NTFS FILESYSTEM
for s in $(sgdisk -p /dev/"$ssdVar" | grep 2700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$ssdVar"p"$s" >/dev/null 2>&1;done

# WINDOWS DATA NTFS FILESYSTEM
for s in $(sgdisk -p /dev/"$hddVar" | grep 0700 | cut -d " " -f3,4);do mkfs.ntfs -Q /dev/"$hddVar""$s" >/dev/null 2>&1;done


echo "Gotovo"




# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 
echo "Stvaram direktorije za Backup GPT struktura"
export saveDIR=~/BACKUP
mkdir -p ~/BACKUP/HDD
mkdir ~/BACKUP/HDD/Linux1

for (( i=1; i<=numberofWininstalls; i++ ))
do
mkdir ~/BACKUP/HDD/Windows10_"$i"
done

mkdir ~/BACKUP/SSD
mkdir ~/BACKUP/SSD/Linux1

for (( i=1; i<=numberofWininstalls; i++ ))
do
mkdir ~/BACKUP/SSD/Windows10_"$i"
done
echo "Gotovo"

# BACKUP FULL TABLES
echo "Spremam GPT sa svim particijama na diskovima"
sgdisk --backup=$saveDIR/HDD/00_HDD_ALLPARTITIONS.gpt /dev/"$hddVar" >/dev/null 2>&1
sgdisk --backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/"$ssdVar" >/dev/null 2>&1
echo "Gotovo"

# COUNT TOTAL PARTITIONS
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)

# BACKUP ONLY LINUX GPT
echo "Spremam Backup Linux GPT strukture"
for (( i=5; i<=totalSSDpartitions; i++ ))
do
sudo sgdisk --delete="$i" /dev/"$ssdVar" >/dev/null 2>&1
done
sudo sgdisk --sort /dev/"$ssdVar" >/dev/null 2>&1
sudo sgdisk --backup=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt /dev/"$ssdVar"
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 count=1 > $saveDIR/SSD/Linux1/01_SSD_Linux1_protectiveMBR.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=1 count=1 > $saveDIR/SSD/Linux1/02_SSD_Linux1_primaryHEADER.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=2 count=1 > $saveDIR/SSD/Linux1/04_SSD_Linux1_backupHEADER.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=3 > $saveDIR/SSD/Linux1/03_SSD_Linux1_GPTPartitions.gpt
echo "Gotovo"

# RESTORE BACKUP GPT WITH ALL PARTITIONS
sudo sgdisk --load-backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/"$ssdVar" >/dev/null 2>&1
sudo sgdisk --load-backup=$saveDIR/HDD/00_HDD_ALLPARTITIONS.gpt /dev/"$hddVar" >/dev/null 2>&1


# Saving Windows STORE partitions
echo "Spremam Backup Store GPT strukture"
mkdir ~/BACKUP/SSD/Windows10_STORE
for (( i=1; i<=$((totalSSDpartitions-4)); i++ ))
     do
	 sgdisk -d "$i" /dev/"$ssdVar" >/dev/null 2>&1
	 done
sgdisk --backup=$saveDIR/SSD/Windows10_STORE/00_SSD_Windows10_STORE.gpt /dev/"$ssdVar" >/dev/null 2>&1
dd if=$saveDIR/SSD/Windows10_STORE/00_SSD_Windows10_STORE.gpt bs=512 count=1 > $saveDIR/SSD/Windows10_STORE/01_SSD_Windows10_STORE_protectiveMBR.gpt
dd if=$saveDIR/SSD/Windows10_STORE/00_SSD_Windows10_STORE.gpt bs=512 skip=1 count=1 > $saveDIR/SSD/Windows10_STORE/02_SSD_Windows10_STORE_primaryHEADER.gpt
dd if=$saveDIR/SSD/Windows10_STORE/00_SSD_Windows10_STORE.gpt bs=512 skip=2 count=1 > $saveDIR/SSD/Windows10_STORE/04_SSD_Windows10_STORE_backupHEADER.gpt
dd if=$saveDIR/SSD/Windows10_STORE/00_SSD_Windows10_STORE.gpt bs=512 skip=3 > $saveDIR/SSD/Windows10_STORE/03_SSD_Windows10_STORE_GPTPartitions.gpt
echo "Gotovo"

# BACKUP WINDOWS GPT STRUCTURES
# A little bit of cleaning first, removing Linux and Store partitions
echo "Malo ciscenja..."
sgdisk --load-backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/"$ssdVar" >/dev/null 2>&1
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)


for (( i=1; i<=4; i++ ))
     do
       sgdisk -d "$i" /dev/"$ssdVar" >/dev/null 2>&1
     done
for (( i=totalSSDpartitions; i>$((totalSSDpartitions-4)); i-- ))
     do
       sgdisk -d $i /dev/"$ssdVar" >/dev/null 2>&1
     done
sgdisk --sort /dev/"$ssdVar" >/dev/null 2>&1
sgdisk --backup=$saveDIR/SSD/00_SSD_CLEANED_PARTITIONS_1.gpt /dev/"$ssdVar" >/dev/null 2>&1



# New partition number calculating
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)
echo "Ukupno ima ""$totalSSDpartitions"" Particija"


# Saving Windows partitions
echo "Spremam Backup Windows GPT strukture"
for (( i=1; i<=numberofWininstalls; i++ ))
    do
      sgdisk --load-backup=$saveDIR/SSD/00_SSD_CLEANED_PARTITIONS_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1
      for (( j=5; j<=totalSSDpartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$ssdVar" >/dev/null 2>&1
        done
    sgdisk --backup=$saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1
    dd if=$saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt bs=512 count=1 > $saveDIR/SSD/Windows10_"$i"/01_SSD_Windows10_"$i"_protectiveMBR.gpt
    dd if=$saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt bs=512 skip=1 count=1 > $saveDIR/SSD/Windows10_"$i"/02_SSD_Windows10_"$i"_primaryHEADER.gpt
    dd if=$saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt bs=512 skip=2 count=1 > $saveDIR/SSD/Windows10_"$i"/04_SSD_Windows10_"$i"_backupHEADER.gpt
    dd if=$saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt bs=512 skip=3 > $saveDIR/SSD/Windows10_"$i"/03_SSD_Windows10_"$i"_GPTPartitions.gpt

    sgdisk --load-backup=$saveDIR/SSD/00_SSD_CLEANED_PARTITIONS_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1

    for (( k=1; k<=4; k++ ))
       do
         sgdisk -r "$k":$((k+4)) /dev/"$ssdVar" >/dev/null 2>&1
       done

    for (( n=5; n<=8; n++))
       do
         sgdisk -d "$n" /dev/"$ssdVar" >/dev/null 2>&1
       done

    sgdisk --sort /dev/"$ssdVar" >/dev/null 2>&1
    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/SSD/00_SSD_CLEANED_PARTITIONS_$var.gpt /dev/"$ssdVar" >/dev/null 2>&1


    totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
    totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)
done
echo "Gotovo"
pause


# Saving Windows populated STORE partitions
echo "Spremam Backup Store GPT strukture sa Windows sustavima"
for (( i=1; i<=numberofWininstalls; i++ ))
do
mkdir $saveDIR/SSD/Windows10_STORE_"$i"
done

mkdir $saveDIR/SSD/Windows10_STORE_TEMP

# Restore full GPT
sgdisk --load-backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/"$ssdVar" >/dev/null 2>&1

# Recalculate partitions 
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)

# Delete  Linux partitions
echo "Brisem Linux particije"

for (( i=1; i<=4; i++ ))
     do
       sgdisk -d "$i" /dev/$ssdVar >/dev/null 2>&1
     done
     sgdisk --sort /dev/$ssdVar
echo "Gotovo"

# Backup Cleaned GPT structure
sgdisk --backup=$saveDIR/SSD/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_1.gpt /dev/"$ssdVar" >/dev/null 2>&1

# Saving STORE partition packages
echo "Spremam PAKETE WindowsStore particija"
for (( i=1; i<=numberofWininstalls; i++ ))
    do
      echo "$i"" Prolaz"
      sgdisk --load-backup=$saveDIR/SSD/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1
    clear    
    echo "Ispis prije brisanja tablica "$i
    sgdisk -p /dev/"$ssdVar"
    pause
    sgdisk --sort /dev/"$ssdVar"
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
for (( j=5; j<=$((totalSSDpartitions-4)); j++ ))
        do
          sgdisk -d $j /dev/"$ssdVar" >/dev/null 2>&1
        done
    clear    
    echo "Ispis nakon brisanja tablica "$i
    sgdisk -p /dev/"$ssdVar"
    pause
    sgdisk --sort /dev/"$ssdVar" 

    for (( k=1; k<=4; k++ ))
       do
         sgdisk -r $k:$(($k+4)) /dev/"$ssdVar" >/dev/null 2>&1
       done
    sgdisk --backup=$saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1
    dd if=$saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt bs=512 count=1 > $saveDIR/SSD/Windows10_STORE_"$i"/01_SSD_Windows10_STORE_"$i"_protectiveMBR.gpt
    dd if=$saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt bs=512 skip=1 count=1 > $saveDIR/SSD/Windows10_STORE_"$i"/02_SSD_Windows10_STORE_"$i"_primaryHEADER.gpt
    dd if=$saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt bs=512 skip=2 count=1 > $saveDIR/SSD/Windows10_STORE_"$i"/04_SSD_Windows10_STORE_"$i"_backupHEADER.gpt
    dd if=$saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt bs=512 skip=3 > $saveDIR/SSD/Windows10_STORE_"$i"/03_SSD_Windows10_STORE_"$i"_GPTPartitions.gpt


sgdisk --load-backup=$saveDIR/SSD/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1
for (( j=1; j<=4; j++ ))
        do
          sgdisk -d $j /dev/"$ssdVar" >/dev/null 2>&1
        done 
  
    sgdisk --sort /dev/"$ssdVar" 
    var=$(( $i + 1 ))

    totalSSDpartitions=$(grep -c nvme0n1p[0-9] /proc/partitions)
    partprobe /dev/"$ssdVar"
    if [ $totalSSDpartitions -lt 5 ];then echo "Gotovo"; break; fi
   sgdisk --backup=$saveDIR/SSD/Windows10_STORE_TEMP/STORE_CLEANED_PARTITIONS_"$var".gpt /dev/"$ssdVar" >/dev/null 2>&1
totalSSDpartitions=$(grep -c "$ssdVar""p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)
done

echo "Gotovo"
echo "Ispisujem spremljene Store/Windows Backup GPT strukture"
for (( i=1; i<=numberofWininstalls; i++ ))
do
sgdisk -l $saveDIR/SSD/Windows10_STORE_"$i"/00_SSD_Windows10_STORE_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1; sudo sgdisk -p /dev/"$ssdVar"
done
pause




# Saving HDD DATA partitions 
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)
echo "Spremam HDD DATA GPT strukture"
for (( i=1; i<=numberofWininstalls; i++ ))
    do
      sgdisk --load-backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_"$i".gpt /dev/"$hddVar" >/dev/null 2>&1
      for (( j=2; j<=totalHDDpartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$hddVar" >/dev/null 2>&1
        done
    sgdisk --backup=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt /dev/"$hddVar" >/dev/null 2>&1
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 count=1 > $saveDIR/HDD/Windows10_"$i"/01_HDD_Windows10_"$i"_protectiveMBR.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=1 count=1 > $saveDIR/HDD/Windows10_"$i"/02_HDD_Windows10_"$i"_primaryHEADER.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=2 count=1 > $saveDIR/HDD/Windows10_"$i"/04_HDD_Windows10_"$i"_backupHEADER.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=3 > $saveDIR/HDD/Windows10_"$i"/03_HDD_Windows10_"$i"_GPTPartitions.gpt

    sgdisk --load-backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_"$i".gpt /dev/"$hddVar" >/dev/null 2>&1

    sgdisk -r 1:$((i+1)) /dev/"$hddVar" >/dev/null 2>&1

    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_$var.gpt /dev/"$hddVar" >/dev/null 2>&1
done
echo "Gotovo"
pause




#### PRINT BACKED UP TABLES
echo "Ispisujem spremljene Windows Backup GPT strukture"
for (( i=1; i<=numberofWininstalls; i++ ))
do
sgdisk -l $saveDIR/SSD/Windows10_"$i"/00_SSD_Windows10_"$i".gpt /dev/"$ssdVar" >/dev/null 2>&1; sudo sgdisk -p /dev/"$ssdVar"
done