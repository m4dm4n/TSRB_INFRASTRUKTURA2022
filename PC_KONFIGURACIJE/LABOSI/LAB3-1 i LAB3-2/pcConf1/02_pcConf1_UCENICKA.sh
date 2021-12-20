#!/bin/bash



# Define some variables here
#---------------------------

echo "Broj win instalacija: " $numberofWininstalls

nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(($nvmeSizeinB/1024/1024))
nvmeSizeinGB=$(($nvmeSizeinB/1024/1024/1024))
hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
hddSizeinMB=$(($hddSizeinB/1024/1024))
hddSizeinGB=$(($hddSizeinB/1024/1024/1024))


linEfiPartinMB=300
linSwapinGB=16
linRootinGB=50
linHomeinGB=30

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( $winRecoveryPartinMB / 1024 ))

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


# PARTITIONING

# Create GPT structure on drives
sgdisk  --mbrtogpt /dev/$ssdVar
sgdisk  --mbrtogpt /dev/$hddVar 


# Create Linux HOME partition

sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$ssdVar
sgdisk -n 3:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$ssdVar
sgdisk -n 4:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$ssdVar
sgdisk -p /dev/$ssdVar
#pause
#echo "Done"

# Create Windows partitions

for (( i=1; i<=$numberofWininstalls; i++ ))
do

sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar

done

# Create BACKUP partition

TotalFreeSectorsNVME=$(sgdisk -p /dev/nvme0n1 | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$((TotalFreeSectorsNVME*512))
TotalFreeinMBNVME=$((TotalFreeinBNVME/1024/1024))
TotalFreeinGBNVME=$((TotalFreeinMBNVME/1024))

sgdisk -p /dev/$ssdVar
pause
clear

winBACKUPinMB=$(($TotalFreeinMBNVME-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-2))
echo "WIN BACKUP SIZE " $winBACKUPinMB



sgdisk -n 0:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 0:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 0:0:+"$winBACKUPinMB"MiB -t 0:0700 -c 0:"STORE"  /dev/$ssdVar
sgdisk -n 0:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar



# Done , print GPT structures

sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar

pause



# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 

export saveDIR=~/BACKUP

mkdir -p ~/BACKUP/HDD
mkdir ~/BACKUP/HDD/Linux1

for (( i=1; i<=$numberofWininstalls; i++ ))
do
mkdir ~/BACKUP/HDD/Windows10_$i
done

mkdir ~/BACKUP/SSD
mkdir ~/BACKUP/SSD/Linux1

for (( i=1; i<=$numberofWininstalls; i++ ))
do
mkdir ~/BACKUP/SSD/Windows10_$i
done

# BACKUP FULL TABLES
sudo -E sgdisk --backup=$saveDIR/HDD/00_HDD_ALLPARTITIONS.gpt /dev/$hddVar
sudo -E sgdisk --backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/$ssdVar

# COUNT TOTAL PARTITIONS
totalSSDpartitions=$(grep -c $ssdVar"p"[0-9] /proc/partitions)
totalHDDpartitions=$(grep -c $hddVar[0-9] /proc/partitions)
echo $totalSSDpartitions
echo $totalHDDpartitions


# BACKUP ONLY LINUX GPT
for (( i=5; i<=$totalSSDpartitions; i++ ))
do
sudo sgdisk --delete=$i /dev/$ssdVar
done
sudo sgdisk --sort /dev/$ssdVar
sudo sgdisk -p /dev/$ssdVar
sudo sgdisk --backup=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt /dev/$ssdVar
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 count=1 > $saveDIR/SSD/Linux1/01_SSD_Linux1_protectiveMBR.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=1 count=1 > $saveDIR/SSD/Linux1/01_SSD_Linux1_primaryHEADER.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=2 count=1 > $saveDIR/SSD/Linux1/01_SSD_Linux1_backupHEADER.gpt
dd if=$saveDIR/SSD/Linux1/00_SSD_Linux1.gpt bs=512 skip=3 > $saveDIR/SSD/Linux1/01_SSD_Linux1_GPTPartitions.gpt
pause