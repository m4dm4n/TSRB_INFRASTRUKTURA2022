#!/bin/bash
clear

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define DATA and SYSTEM drive
dataDrive=sda
sysDrive=nvme0n1


#Clear all GPT structures
echo -n "Zapping previous GPT structures..."
sgdisk --zap-all /dev/$dataDrive >/dev/null 2>&1
sgdisk --zap-all /dev/$sysDrive >/dev/null 2>&1
echo -e "${GREEN}      Done${NC}"

# Create GPT structure
echo -n "Creating new GPT structures..."
sgdisk  --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/$sysDrive >/dev/null 2>&1
echo -e "${GREEN}      Done${NC}"


###########################################
###### CREATING SYSTEM PARTITIONS #########
###########################################
echo -n "Creating System Partitions..."
#Create Linux partitions
sgdisk -n 1:1MiB:500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+8GiB -t 0:8200 -c 0:swap /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+30GiB -t 0:8304 -c 0:root /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+50GiB -t 0:8302 -c 0:home /dev/$sysDrive >/dev/null 2>&1

#Create Win01 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows01"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10000MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win02 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows02"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win03 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows03"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win04 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows04"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win05 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows05"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win06 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"WindowsSEM"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"



###########################################
######## CREATING DATA PARTITIONS #########
###########################################
echo -n "Creating Data Partitions..."
# NVME DISK
sgdisk -n 0:0:+250GiB -t 0:0700 -c 0:"G3ssdData"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+450GiB -t 0:0700 -c 0:"G4ssdData"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+300GiB -t 0:0700 -c 0:"G5ssdData"  /dev/$sysDrive >/dev/null 2>&1

# HDD DISK
sgdisk -n 1:1MiB:300GiB -t 0:0700 -c 0:"G1Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+500GiB -t 0:0700 -c 0:"G2Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+500GiB -t 0:0700 -c 0:"G3Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+500GiB -t 0:0700 -c 0:"G4Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+1000GiB -t 0:0700 -c 0:"G5Data" /dev/$dataDrive >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"

############################################
#########Modify Partitions UUID#############
############################################
echo -n "Modifying Partitions UUIDs..."
#Linux
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-4C494E303031 /dev/$sysDrive
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-4C494E303032 /dev/$sysDrive
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-4C494E303033 /dev/$sysDrive
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-4C494E303034 /dev/$sysDrive

#Win01
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-57494E303031 /dev/$sysDrive
sgdisk --partition-guid=6:54535242-4D42-4D53-5A47-57494E303032 /dev/$sysDrive
sgdisk --partition-guid=7:54535242-4D42-4D53-5A47-57494E303033 /dev/$sysDrive
sgdisk --partition-guid=8:54535242-4D42-4D53-5A47-57494E303034 /dev/$sysDrive

#Win02
sgdisk --partition-guid=9:54535242-4D42-4D53-5A47-57494E303035 /dev/$sysDrive
sgdisk --partition-guid=10:54535242-4D42-4D53-5A47-57494E303036 /dev/$sysDrive
sgdisk --partition-guid=11:54535242-4D42-4D53-5A47-57494E303037 /dev/$sysDrive
sgdisk --partition-guid=12:54535242-4D42-4D53-5A47-57494E303038 /dev/$sysDrive

#Win03
sgdisk --partition-guid=13:54535242-4D42-4D53-5A47-57494E303039 /dev/$sysDrive
sgdisk --partition-guid=14:54535242-4D42-4D53-5A47-57494E303130 /dev/$sysDrive
sgdisk --partition-guid=15:54535242-4D42-4D53-5A47-57494E303131 /dev/$sysDrive
sgdisk --partition-guid=16:54535242-4D42-4D53-5A47-57494E303132 /dev/$sysDrive

#Win04
sgdisk --partition-guid=17:54535242-4D42-4D53-5A47-57494E303133 /dev/$sysDrive
sgdisk --partition-guid=18:54535242-4D42-4D53-5A47-57494E303134 /dev/$sysDrive
sgdisk --partition-guid=19:54535242-4D42-4D53-5A47-57494E303135 /dev/$sysDrive
sgdisk --partition-guid=20:54535242-4D42-4D53-5A47-57494E303136 /dev/$sysDrive

#Win05
sgdisk --partition-guid=21:54535242-4D42-4D53-5A47-57494E303137 /dev/$sysDrive
sgdisk --partition-guid=22:54535242-4D42-4D53-5A47-57494E303138 /dev/$sysDrive
sgdisk --partition-guid=23:54535242-4D42-4D53-5A47-57494E303139 /dev/$sysDrive
sgdisk --partition-guid=24:54535242-4D42-4D53-5A47-57494E303230 /dev/$sysDrive

#Win06
sgdisk --partition-guid=25:54535242-4D42-4D53-5A47-57494E303231 /dev/$sysDrive
sgdisk --partition-guid=26:54535242-4D42-4D53-5A47-57494E303232 /dev/$sysDrive
sgdisk --partition-guid=27:54535242-4D42-4D53-5A47-57494E303233 /dev/$sysDrive
sgdisk --partition-guid=28:54535242-4D42-4D53-5A47-57494E303234 /dev/$sysDrive

#DATA PARTITIONS
#NVME
sgdisk --partition-guid=29:54535242-4D42-4D53-5A47-535344303031 /dev/$sysDrive
sgdisk --partition-guid=30:54535242-4D42-4D53-5A47-535344303032 /dev/$sysDrive
sgdisk --partition-guid=31:54535242-4D42-4D53-5A47-535344303033 /dev/$sysDrive
#HDD
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-484444303031 /dev/$dataDrive
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-484444303032 /dev/$dataDrive
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-484444303033 /dev/$dataDrive
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-484444303034 /dev/$dataDrive
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-484444303035 /dev/$dataDrive

echo -e "${GREEN}      Done${NC}"

###########################################
####Creating NVME Filesystems##############
###########################################
echo -n "Creating Filesystems..."
#Linux SWAP
mkswap /dev/"$sysDrive"p2 >/dev/null 2>&1
#Linux EXT4
for i in {3,4}; do mkfs.ext4 -F /dev/"$sysDrive"p"$i" >/dev/null 2>&1; done
#WinXY FAT32
for i in {1,5,9,13,17,21,25}; do mkfs.vfat -F 32 /dev/"$sysDrive"p"$i" >/dev/null 2>&1; done
#WinXY NTFS
for i in {7,8,11,12,15,16,19,20,23,24,27,28,29,30,31}; do mkfs.ntfs -Q /dev/"$sysDrive"p"$i" >/dev/null 2>&1; done

###########################################
#####Creating HDD Filesystems##############
###########################################
#dataXY NTFS
for i in {1..5}; do mkfs.ntfs -Q /dev/"$dataDrive""$i" >/dev/null 2>&1; done

echo -e "${GREEN}      Done${NC}"


###########################################
######Creating System GPT Backups##########
###########################################
echo -n "Backupping System Partition Structures..."
mkdir /tmp/GPT05_Backup
workDir="/tmp/GPT05_Backup"


#Backup All partitions
sgdisk --backup="$workDir"/All_Partitions.gpt /dev/$sysDrive

#Backup Linux partitions
for i in {5..31}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Linux_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive

#Backup Win01 partitions
for i in {1..4}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {9..31}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win01_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive


#Backup Win02 partitions
for i in {1..8}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {13..31}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win02_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive


#Backup Win03 partitions
for i in {1..12}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {17..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {30..31}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win03_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive


#Backup Win04 partitions
for i in {1..16}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {21..29}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --delete=31 /dev/$sysDrive >/dev/null 2>&1
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win04_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive


#Backup Win05 partitions
for i in {1..20}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {25..30}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win05_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive


#Backup Win06 partitions
for i in {1..24}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {29..30}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive
sgdisk --backup="$workDir"/Win06_Partitions.gpt /dev/$sysDrive
sgdisk --load-backup="$workDir"/All_Partitions.gpt /dev/$sysDrive

echo -e "${GREEN}      Done${NC}"


###########################################
######Creating Data GPT Backups##########
###########################################
echo -n "Backupping Data Partition Structures..."
sgdisk --backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {2..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G1data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

sgdisk --delete=1 /dev/$dataDrive >/dev/null 2>&1
for i in {3..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G2data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..2}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
for i in {4..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G3data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..3}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --delete=5 /dev/$dataDrive >/dev/null 2>&1
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G4data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..4}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G5data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

echo -e "${GREEN}      Done${NC}"