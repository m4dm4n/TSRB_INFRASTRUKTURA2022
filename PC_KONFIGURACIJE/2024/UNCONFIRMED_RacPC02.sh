#!/bin/bash
clear

##########
# Set some options
set -o errexit # It will exit on first error in script
set -o pipefail # It will exit on first error in some pipeline
##########

##########
# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Run the script with root permissions (sudo ./script_name.sh)"
  exit 1
fi
#########


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
echo -e "${GREEN}             Done${NC}"

# Create GPT structure
echo -n "Creating new GPT structures..."
sgdisk  --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/$sysDrive >/dev/null 2>&1
echo -e "${GREEN}                 Done${NC}"

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

echo -e "${GREEN}                  Done${NC}"


###########################################
######## CREATING DATA PARTITIONS #########
###########################################
echo -n "Creating Data Partitions..."
sgdisk -n 1:1MiB:150GiB -t 0:0700 -c 0:"G1Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+150GiB -t 0:0700 -c 0:"G2Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+150GiB -t 0:0700 -c 0:"G3Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+150GiB -t 0:0700 -c 0:"G4Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+300GiB -t 0:0700 -c 0:"G5Data" /dev/$dataDrive >/dev/null 2>&1

echo -e "${GREEN}                    Done${NC}"


############################################
#########Modify Partitions UUID#############
############################################
echo -n "Modifying Partitions UUIDs..."
#Linux
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-4C494E303031 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-4C494E303032 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-4C494E303033 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-4C494E303034 /dev/$sysDrive >/dev/null 2>&1

#Win01
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-57494E303031 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=6:54535242-4D42-4D53-5A47-57494E303032 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=7:54535242-4D42-4D53-5A47-57494E303033 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=8:54535242-4D42-4D53-5A47-57494E303034 /dev/$sysDrive >/dev/null 2>&1

#Win02
sgdisk --partition-guid=9:54535242-4D42-4D53-5A47-57494E303035 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=10:54535242-4D42-4D53-5A47-57494E303036 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=11:54535242-4D42-4D53-5A47-57494E303037 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=12:54535242-4D42-4D53-5A47-57494E303038 /dev/$sysDrive >/dev/null 2>&1

#Win03
sgdisk --partition-guid=13:54535242-4D42-4D53-5A47-57494E303039 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=14:54535242-4D42-4D53-5A47-57494E303130 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=15:54535242-4D42-4D53-5A47-57494E303131 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=16:54535242-4D42-4D53-5A47-57494E303132 /dev/$sysDrive >/dev/null 2>&1

#Win04
sgdisk --partition-guid=17:54535242-4D42-4D53-5A47-57494E303133 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=18:54535242-4D42-4D53-5A47-57494E303134 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=19:54535242-4D42-4D53-5A47-57494E303135 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=20:54535242-4D42-4D53-5A47-57494E303136 /dev/$sysDrive >/dev/null 2>&1

#Win05
sgdisk --partition-guid=21:54535242-4D42-4D53-5A47-57494E303137 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=22:54535242-4D42-4D53-5A47-57494E303138 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=23:54535242-4D42-4D53-5A47-57494E303139 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=24:54535242-4D42-4D53-5A47-57494E303230 /dev/$sysDrive >/dev/null 2>&1

#Win06
sgdisk --partition-guid=25:54535242-4D42-4D53-5A47-57494E303231 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=26:54535242-4D42-4D53-5A47-57494E303232 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=27:54535242-4D42-4D53-5A47-57494E303233 /dev/$sysDrive >/dev/null 2>&1
sgdisk --partition-guid=28:54535242-4D42-4D53-5A47-57494E303234 /dev/$sysDrive >/dev/null 2>&1

#DATA PARTITIONS
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-484444303031 /dev/$dataDrive >/dev/null 2>&1
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-484444303032 /dev/$dataDrive >/dev/null 2>&1
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-484444303033 /dev/$dataDrive >/dev/null 2>&1
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-484444303034 /dev/$dataDrive >/dev/null 2>&1
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-484444303035 /dev/$dataDrive >/dev/null 2>&1


echo -e "${GREEN}                  Done${NC}"   


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
for i in {7,8,11,12,15,16,19,20,23,24,27,28}; do mkfs.ntfs -Q /dev/"$sysDrive"p"$i" >/dev/null 2>&1; done

###########################################
#####Creating HDD Filesystems##############
###########################################
#dataXY NTFS
for i in {1..5}; do mkfs.ntfs -Q /dev/"$dataDrive""$i" >/dev/null 2>&1; done


echo -e "${GREEN}                        Done${NC}"


###########################################
######Creating System GPT Backups##########
###########################################
echo -n "Backupping System Partition Structures..."

mkdir /tmp/GPT02_Backup
workDir="/tmp/GPT02_Backup"

#Backup All partitions
sgdisk --backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1

#Backup Linux partitions
for i in {5..28}; do sgdisk --delete=$i /dev/$sysDrive; done >/dev/null 2>&1
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Linux_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1

#Backup Win01 partitions
for i in {1..4}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {9..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win01_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1


#Backup Win02 partitions
for i in {1..8}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {13..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win02_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1


#Backup Win03 partitions
for i in {1..12}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {17..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win03_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1


#Backup Win04 partitions
for i in {1..16}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {21..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win04_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1


#Backup Win05 partitions
for i in {1..20}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
for i in {25..28}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win05_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1


#Backup Win06 partitions
for i in {1..24}; do sgdisk --delete=$i /dev/$sysDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$sysDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02Win06_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Partitions.gpt /dev/$sysDrive >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"


###########################################
######Creating Data GPT Backups##########
###########################################
echo -n "Backupping Data Partition Structures..."
sgdisk --backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1

for i in {2..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02G1data_Partition.gpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1

sgdisk --delete=1 /dev/$dataDrive >/dev/null 2>&1
for i in {3..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02G2data_Partition.gpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1

for i in {1..2}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
for i in {4..5}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02G3data_Partition.gpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1

for i in {1..3}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --delete=5 /dev/$dataDrive >/dev/null 2>&1
sgdisk --sort /dev/$dataDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02G4data_Partition.gpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1

for i in {1..4}; do sgdisk --delete=$i /dev/$dataDrive >/dev/null 2>&1; done
sgdisk --sort /dev/$dataDrive >/dev/null 2>&1
sgdisk --backup="$workDir"/pc02G5data_Partition.gpt /dev/$dataDrive >/dev/null 2>&1
sgdisk --load-backup="$workDir"/pc02All_Data_Partitions.gpt /dev/$dataDrive >/dev/null 2>&1


echo -e "${GREEN}                Done${NC}"
echo -e "${GREEN} All Done ${NC}"